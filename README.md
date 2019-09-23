# `SWC_BATCH_CHECK v.1.0`

[![GitHub license](https://img.shields.io/badge/license-GPL_2.0-orange.svg)](https://raw.githubusercontent.com/dohalloran/SWC_BATCH_CHECK/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/dohalloran/SWC_BATCH_CHECK.svg)](https://github.com/dohalloran/SWC_BATCH_CHECK/issues)

- [x] `Batch validation of directory containing SWC files`
- [x] `Ensures structures are correctly connected`
- [x] `Fix structures with zero size diameter `
- [x] `Corrects index sequence`
- [x] `Reports on missing data`
- [x] `Ensures file starts with soma`
- [x] `Returns basic statistics for each file` 


## Installation
1. Download and extract the SWC_BATCH_CHECK.zip file  
`tar -xzvf SWC_BATCH_CHECK.zip`
or 
`git clone https://github.com/dohalloran/SWC_BATCH_CHECK.git`

2. `cd SWC_BATCH_CHECK-master`

3. `chmod +x install.sh`

4. `./install.sh` or `sudo ./install.sh`
if dependency fails you can try using force `--force` 

on MacOS Majave you will need Xcode, CommandLineTools, and headers
Install Xcode and then the CommandLineTools from Xcode

For headers:
`xcode-select --install`
`open /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg`

5.  
```cmd    
perl Makefile.PL  
make  
make test  
make install  
```
might need to `sudo make install` depending on permissions

## Usage 
### To run:  
```perl
use SWC_BATCH_CHECK;
use Modern::Perl;

my $app = SWC_BATCH_CHECK->new_with_options();
$app->run_SWC_BATCH_CHECK(); 
#see below for command flags
``` 
## Command Line Arguments
### Flags
 ```perl   
#path to input directory containing SWC files (required)
        --d ./my_SWC_directory/
#provide corrections to soma that are not connected to other soma       
        --soma
#ensures apical dendrites are connected to apical dendrite or soma
        --apic
#same as --apic flag except for basal dendrite
        --basal
#converts radius = 0 entries to that of its parent's radius
        --rad
#compression of output SWC directory
        --zip
#print flag options to stdout
        --help 
```

### References
1. [SWC Format Specification](http://www.neuronland.org/NLMorphologyConverter/MorphologyFormats/SWC/Spec.html)

2. [SWC+ Plus Format Specification](https://neuroinformatics.nl/swcPlus/)

3. Stockley, E. W., Cole, H. M., Brown, A. D. and Wheal, H. V. (1993) A system for quantitative morphological measurement and electronic modelling of neurons: three-dimensional reconstruction. Journal of Neuroscience Methods, 47, 39-51


## Testing

SWC_BATCH_CHECK was successfully tested on:

- [x] Microsoft Windows 7 Enterprise ver.6.1
- [x] MacOSX Mojave ver.10.14.5
- [x] Linux Mint ver.19 Tara


## Contributing
All contributions are welcome.

## Support
If you have any problem or suggestion please open an issue [here](https://github.com/dohalloran/SWC_BATCH_CHECK/issues).

## License 
GNU GENERAL PUBLIC LICENSE





