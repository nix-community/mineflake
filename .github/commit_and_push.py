"""File for committing and pushing current changes to GitHub.

Using this in CI for committing files with GitHub GraphQL API, because
when you're committing with API, there will be *verified* label.

.. note::
    This will actually run ``git add .`` and ``git pull`` in the end,
    so consider **do not run** this, if you will not debug it.
"""
import argparse
import base64
import dataclasses
import json
import os
import typing

import git
import requests

repo: git.Repo
"""Repository object for GIT interactions."""


def _create_repo() -> git.Repo:
    """Create the git's repository object.

    .. warn:: It will execute ``git add .`` before returning.

    Returns:
        Repository object.
    """
    repo = git.Repo(os.getcwd())
    repo.git.add(".")
    return repo


def _calculate_file_content(path: str) -> str:
    """Open file and encrypt it content with base64.

    Args:
        path: Path to file.

    Returns:
        Base64 encoded content of file.
    """
    with open(path, "rb") as file:
        return base64.b64encode(file.read()).decode()


@dataclasses.dataclass
class FileAddition:
    """Represents `FileAddition https://docs.github.com/en/graphql/reference/input-objects#fileaddition`_ object."""

    path: str
    """Path to file."""
    contents: str
    """Base64 encoded content of file."""


@dataclasses.dataclass
class FileDeletion:
    """Represents `FileDeletion https://docs.github.com/en/graphql/reference/input-objects#filedeletion`_ object."""

    path: str
    """Path to file."""


@dataclasses.dataclass
class FileChanges:
    """Represents `FileChanges https://docs.github.com/en/graphql/reference/input-objects#filechanges`_ object."""

    additions: typing.List[FileAddition] = dataclasses.field(default_factory=list)
    """List of additions in future commit."""
    deletions: typing.List[FileDeletion] = dataclasses.field(default_factory=list)
    """List of deletions in future commit."""

    def merge(self, other: "FileChanges") -> "FileChanges":
        """Merge two :class:`.FileChanges` objects.

        Args:
            other: Other :class:`.FileChanges` object.

        Returns:
            New :class:`.FileChanges` object with changes from both previous objects.
        """
        return FileChanges(
            additions=self.additions + other.additions,
            deletions=self.deletions + other.deletions,
        )

    def __str__(self) -> str:
        """Build JSON string representation of :class:`.FileChanges` object.

        .. note:: It's hiding :attr:`.FileAddition.contents` attribute, because this is just a spam.

        Returns:
            JSON string representation of :class:`.FileChanges` object.
        """
        result = dataclasses.asdict(self)
        for item in result["additions"]:
            item["contents"] = "..."

        return json.dumps(result)

    def __bool__(self) -> bool:
        """Check if :class:`.FileChanges` object is empty.

        Returns:
            :obj:`True` if :class:`.FileChanges` object is empty, :obj:`False` otherwise.
        """
        return bool(self.additions or self.deletions)


@dataclasses.dataclass
class NewFile:
    """Represents new file in future commit."""

    path: str
    """Path to file."""

    def to_file_changes(self) -> FileChanges:
        """Convert :class:`.NewFile` object to :class:`.FileChanges` object.

        Returns:
            :class:`.FileChanges` object.
        """
        return FileChanges(
            additions=[FileAddition(path=self.path, contents=_calculate_file_content(self.path))],
        )


@dataclasses.dataclass
class ModifiedFile(NewFile):
    """Represents modified file in future commit.

    All logic the same as in :class:`.NewFile` class.
    """


@dataclasses.dataclass
class DeletedFile(FileDeletion):
    """Represents deleted file in future commit."""

    def to_file_changes(self) -> FileChanges:
        """Convert :class:`.DeletedFile` object to :class:`.FileChanges` object.

        Returns:
            :class:`.FileChanges` object.
        """
        return FileChanges(deletions=[FileDeletion(path=self.path)])


@dataclasses.dataclass
class RenamedFile:
    """Represents renamed file in future commit."""

    new_path: str
    old_path: str

    def to_file_changes(self) -> FileChanges:
        """Convert :class:`.RenamedFile` object to :class:`.FileChanges` object.

        Returns:
            :class:`.FileChanges` object.
        """
        return FileChanges(
            additions=[FileAddition(path=self.new_path, contents=_calculate_file_content(self.new_path))],
            deletions=[FileDeletion(path=self.old_path)],
        )


def get_diff() -> git.diff.DiffIndex:
    """Getter for the diff.

    Returns:
        Diff object.
    """
    return repo.index.diff(None, staged=True)


def get_latest_commit() -> str:
    """Just a getter for a latest commit.

    Returns:
        Latest commit.
    """
    return str(repo.rev_parse("HEAD"))


def calculate_file_changes(diff: git.diff.DiffIndex) -> FileChanges:
    """Calculating `FileChanges https://docs.github.com/en/graphql/reference/input-objects#filechanges`_ object from \
    :class:`git.diff.DiffIndex` object.

    Args:
        diff: :class:`git.diff.DiffIndex` object.

    Returns:
        Generated `FileChanges https://docs.github.com/en/graphql/reference/input-objects#filechanges`_ object
        or None if it's empty.
    """
    file_changes = FileChanges()
    for changed in diff:
        if changed.change_type == "A":
            file_changes = file_changes.merge(NewFile(path=changed.a_path).to_file_changes())
        elif changed.change_type == "D":
            file_changes = file_changes.merge(DeletedFile(path=changed.b_path).to_file_changes())
        elif changed.change_type == "R":
            file_changes = file_changes.merge(
                RenamedFile(new_path=changed.b_path, old_path=changed.a_path).to_file_changes()
            )
        elif changed.change_type == "M":
            file_changes = file_changes.merge(ModifiedFile(path=changed.b_path).to_file_changes())
        else:  # pragma: no cover
            # I don't really understand what is undocumented change types here.
            # Will implement it in the future, if I will find what is this.
            raise ValueError(f"Unknown change type: {changed.change_type}")

    return file_changes if bool(file_changes) else None


def _git_pull() -> None:
    """Pulling latest changes from the remote repository."""
    repo.remotes.origin.pull()


def generate_request_data(args: argparse.Namespace, file_changes: FileChanges) -> typing.Tuple[tuple, dict]:
    """Generate request data from arguments and :class:`.FileChanges` object.

    Args:
        args: Arguments from command line.
        file_changes: :class:`.FileChanges` object.

    Returns:
        Tuple with request data and request headers, it should be passed directly in :func:`requests.post` call.
    """
    return ("https://api.github.com/graphql",), {
        "headers": {
            "Authorization": f"bearer {args.token}",
            "Accept": "application/vnd.github.v4.idl",
        },
        "data": json.dumps(
            {
                "query": "mutation ($input: CreateCommitOnBranchInput!) {createCommitOnBranch(input: $input) {commit {url}}}",
                "variables": {
                    "input": {
                        "branch": {"repositoryNameWithOwner": args.repository, "branchName": args.branch},
                        "message": {"headline": args.message},
                        "fileChanges": dataclasses.asdict(file_changes),
                        "expectedHeadOid": get_latest_commit(),
                    }
                },
            }
        ),
    }


def send_http_request(args: tuple, kwargs: dict) -> typing.Iterable[dict]:
    """Send HTTP request to GitHub API.

    Args:
        args: Tuple of arguments for HTTP request.
        kwargs: Dictionary of keyword arguments for HTTP request.

    Yields:
        JSON response on first iteration, and on second it's just checking for errors.

    Example:
        .. code-block:: python
            for response in send_http_request(("https://api.github.com/graphql",), {}):
                # lines here will be run only once, on next iteration it will check for errors and exit.
                print(response)
    """
    response = requests.post(*args, **kwargs)
    yield response.json()
    response.raise_for_status()
    if "errors" in response.json():
        raise ValueError(
            "Github raised error(s): \n" + "\n".join(error["message"] for error in response.json()["errors"])
        )


def parse_args() -> argparse.Namespace:  # pragma: no cover # no sense to test it
    """Parse arguments with :class:`argparse.ArgumentParser`.

    Returns:
        Parsed arguments.
    """
    parser = argparse.ArgumentParser(
        description="Commit and push changes to GitHub with GitHub API.",
        epilog="WARNING: This script will run `git add .` and `git pull` in the end.",
    )

    parser.add_argument("repository", help="The repository to commit and push.")
    parser.add_argument("branch", help="Branch to commit and push.")
    parser.add_argument("message", help="Commit message.")
    parser.add_argument("--token", "-t", help="GitHub token.", required=True)

    return parser.parse_args()


def get_welcome_info(args: argparse.Namespace) -> str:
    """Getter for the welcome info.

    Args:
        args: Parsed arguments to script.

    Returns:
        Some helpful welcome info.
    """
    return f"""\
Repository to commit and push: '{args.repository}'.
Branch to commit and push: '{args.branch}'.
Commit message: '{args.message}'.
Latest commit: '{get_latest_commit()}'\
"""


def main() -> typing.Iterable[str]:
    """Main function.

    Yields:
        Strings to print.
    """
    args = parse_args()
    yield get_welcome_info(args)

    file_changes = calculate_file_changes(get_diff())
    yield "File changes: " + str(file_changes)
    if not file_changes:
        return "Nothing to commit."

    for response in send_http_request(*generate_request_data(args, file_changes)):
        yield f"\nResponse from GitHub: {response}"

    yield "\nPerforming `git pull`..."
    _git_pull()

    yield (
        f"Congratulations! I'm done! Here is the link to your commit: {response['data']['createCommitOnBranch']['commit']['url']}"
    )


if __name__ == "__main__":
    repo = _create_repo()

    for to_print in main():
        print(to_print)
