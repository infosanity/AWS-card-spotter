# AWS-card-spotter
Identify if credit (or debit, etc.) cards are included in an image

## Config
```
mv config.py.template config.py
```

**bucket** is *your* S3 bucket

**images** is list of hardcoded (for now) filenames to scan within bucket

## Example Output
* [S3 Bucket Here] Credit Card Identified in Black-Credit-Card-Mockup.jpg: 86 Confidence
* [S3 Bucket Here] Credit Card Identified in CreditCard.png: 91 Confidence
* [S3 Bucket Here] Credit Card Identified in credit-card-perspective.jpg: 93 Confidence
