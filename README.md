# Useful Functions
A repository for any functions I create that I will reuse.

# report_details
This is a function which calculates the current wordcount of the current markdown file as well as saving a copy of the markdown file and additional comments on the version if required. The final two points are entered by the user when knitting in the knit with parameters option. If the usual knit button is clicked then the option to save the document will not be available. This is useful for version control of a document in a local setting.

#### Pre-requisites
The code requires the installation of the _wordcountaddin_ created by @benmarwick in order to calculate the wordcount. You can download this following the instructions here: https://github.com/benmarwick/wordcountaddin. You will also need to create locations for the original markdown report, details csv file and the archive folder. For ease i had them all in an R Trial folder in my current directory, with the archive files having a folder within this.
