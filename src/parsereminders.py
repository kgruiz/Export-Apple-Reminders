import json
from pathlib import Path

from rich import box
from rich.align import Align
from rich.console import Console, Group
from rich.padding import Padding
from rich.panel import Panel
from rich.progress import (
    BarColumn,
    MofNCompleteColumn,
    Progress,
    SpinnerColumn,
    TextColumn,
    TimeElapsedColumn,
    TimeRemainingColumn,
)
from rich.rule import Rule
from rich.table import Table
from rich.text import Text

console = Console()


# Progress(
#     SpinnerColumn(),
#     TextColumn("[bold blue]{task.description}", justify="left"),
#     TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
#     BarColumn(bar_width=None),
#     MofNCompleteColumn(),
#     TextColumn("•"),
#     TimeElapsedColumn(),
#     TextColumn("•"),
#     TimeRemainingColumn(),
#     expand=True,
# )


def ReadReminders(remindersPath: Path | str = Path("reminders.json")):

    remindersPath = Path(remindersPath)

    if not remindersPath.exists():

        console.print(f"[red]Error:[/] File {remindersPath} does not exist.")

        raise FileNotFoundError(f"File {remindersPath} does not exist.")

    with open(remindersPath, "r") as file:

        reminders = json.load(file)

    return reminders


def GetCompleted(reminders):

    completed = [reminder for reminder in reminders if reminder["isCompleted"]]

    return completed


def GetUnCompleted(reminders):

    uncompleted = [reminder for reminder in reminders if not reminder["isCompleted"]]

    return uncompleted


def GetWithDueDate(reminders):

    withDueDate = [
        reminder for reminder in reminders if "dueDateComponents" in reminder
    ]

    return withDueDate


def GetWithoutDueDate(reminders):

    withoutDueDate = [
        reminder for reminder in reminders if "dueDateComponents" not in reminder
    ]

    return withoutDueDate


if __name__ == "__main__":

    reminders = ReadReminders()

    completed = GetCompleted(reminders)

    console.print(f"Completed: {len(completed)}")

    completedPath = Path("completed.json")

    with open(completedPath, "w") as file:

        json.dump(completed, file, indent=4)

    console.print(f"Completed reminders written to {completedPath}")

    uncompleted = GetUnCompleted(reminders)

    console.print(f"Uncompleted: {len(uncompleted)}")

    uncompletedPath = Path("uncompleted.json")

    with open(uncompletedPath, "w") as file:

        json.dump(uncompleted, file, indent=4)

    console.print(f"Uncompleted reminders written to {uncompletedPath}")

    withDueDate = GetWithDueDate(uncompleted)

    console.print(f"Uncompleted with due date: {len(withDueDate)}")

    withDueDatePath = Path("withDueDate.json")

    with open(withDueDatePath, "w") as file:

        json.dump(withDueDate, file, indent=4)

    console.print(f"Uncompleted reminders with due date written to {withDueDatePath}")

    withoutDueDate = GetWithoutDueDate(uncompleted)

    console.print(f"Uncompleted without due date: {len(withoutDueDate)}")

    withoutDueDatePath = Path("withoutDueDate.json")

    with open(withoutDueDatePath, "w") as file:

        json.dump(withoutDueDate, file, indent=4)

    console.print(
        f"Uncompleted reminders without due date written to {withoutDueDatePath}"
    )
