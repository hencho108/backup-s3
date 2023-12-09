import logging

import yaml

from src.utils import DotDict


def load_config(file_path: str) -> DotDict:
    """
    Handles loading configuration from the YAML file.
    """
    with open(file_path, "r") as file:
        config = yaml.safe_load(file)

    return DotDict(config)


def configure_logging():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
