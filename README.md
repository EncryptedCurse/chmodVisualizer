# chmodVisualizer
A utility that prints a nicely formatted table of Linux file permissions to make them easier to understand.

<p align="center"><img src="https://i.imgur.com/LJKuwa5.png"></p>

You may notice that there are two versions in this repo. I originally wrote this in Python, but found the performance to be a bit lacking. That is not to say that it is slow, but the Bash version is naturally more responsive.

**The Python version requires [Colorama](https://pypi.org/project/colorama/) to be installed.**

## Usage
This tool works through command-line arguments. You may either directly specify a permission mask (e.g. `755`) or the path of a file if you are unsure.
