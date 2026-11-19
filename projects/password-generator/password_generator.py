"""
Generate a password from selected ASCII character sets.

For example, call PasswordGenerator().generate_random_password(lowercase=True)
to sample from ASCII lowercase letters.
The method returns display text, including an error message if choosing a
length or sampling fails.
It uses Python's random module, which is unsuitable for generating secrets.
"""

import string
import random
import sys

class PasswordGenerator:
    def __init__(self):
        pass

    def generate_random_password(self, min_length=8, max_length=16, fixed_length=8, lowercase=False, uppercase=False, digits=False, special_characters=False):
        """
        Sample with replacement from the combined enabled sets. Enabling a set
        makes its characters eligible. A sample may omit that set entirely.

        Pick an inclusive length between min_length and max_length. The
        fixed_length argument is ignored. Invalid bounds and an empty pool
        with a positive sample length both return "Error: No options selected".
        """

        try:
            string_size = random.randint(min_length, max_length)
            combination = ''
            if lowercase: combination += string.ascii_lowercase
            if uppercase: combination += string.ascii_uppercase
            if digits: combination += string.digits
            if special_characters: combination += string.punctuation

            password = ''.join(random.choices(combination, k=string_size))

            return password

        except:
            return "Error: No options selected"

if __name__ == "__main__":
    print(PasswordGenerator().generate_random_password())
