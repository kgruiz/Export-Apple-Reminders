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


def ParseReminders(remindersPath: Path | str = Path("reminders.json")):

    remindersPath = Path(remindersPath)

    if not remindersPath.exists():

        console.print(f"[red]Error:[/] File {remindersPath} does not exist.")

        raise FileNotFoundError(f"File {remindersPath} does not exist.")

    with open(remindersPath, "r") as file:

        reminders = json.load(file)

    print(json.dumps(reminders, indent=4))


if __name__ == "__main__":

    ParseReminders()
