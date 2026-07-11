from abc import ABC, abstractmethod
from xml.etree.ElementTree import Element


class AbstractTranslator(ABC):
    """Abstract base class for translators that convert string data to XML elements."""

    @abstractmethod
    def translate(self, input_data: bytes) -> Element:
        """
        Translate input string data to an XML element.

        Args:
            input_data: The input string to be translated

        Returns:
            An XML Element representing the translated data
        """
        pass
