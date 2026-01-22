import requests
from pathlib import Path

# Dataset URL
URL = "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/stationdata/heathrowdata.txt"

# Local path
DATA_DIR = Path("data/raw")
DATA_DIR.mkdir(parents=True, exist_ok=True)

FILE_PATH = DATA_DIR / "heathrow_monthly_weather.txt"


def download_data(url: str, path: Path) -> None:
    response = requests.get(url)
    response.raise_for_status()  # fail loudly if download fails

    path.write_text(response.text)
    print(f"Downloaded data to {path}")


if __name__ == "__main__":
    download_data(URL, FILE_PATH)
