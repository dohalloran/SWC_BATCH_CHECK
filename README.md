# `SWC_BATCH_CHECK v.1.0`

[![GitHub license](https://img.shields.io/badge/license-GPL_2.0-orange.svg)](https://raw.githubusercontent.com/dohalloran/SWC_BATCH_CHECK/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/dohalloran/SWC_BATCH_CHECK.svg)](https://github.com/dohalloran/SWC_BATCH_CHECK/issues)

- [x] `Batch validation of directory containing SWC files`
- [x] `Ensures structures are correcrly connected`
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
2. The extracted dir will be called SWC_BATCH_CHECK  
```cmd  
cd fastQ_brew   
perl Makefile.PL  
make  
make test  
make install  
```

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
#path to input directory containing SWC files
        --d ./my_SWC_directory
#provide corrections to soma that are not connected to other soma       
        --soma
#ensures apical dendrites are connected to apical dendrite or soma
        --apic
#same as --apic flag except for basal dendrite
        --basal
#converts radius = 0 entries to that of its parent's radius
        --rad
#print flag options to stdout
        --help 
```

### References
1. Cock PJ, Fields CJ, Goto N, Heuer ML, Rice PM. The Sanger FASTQ file format for sequences with quality scores, and the Solexa/Illumina FASTQ variants. Nucleic Acids Res. 2010;38(6):1767–71

2. Ewing B, Hillier L, Wendl MC, Green P. Base-calling of automated sequencer traces using phred. I. Accuracy assessment. Genome Res. 1998;8(3):175–85.

3. Ewing B, Green P. Base-calling of automated sequencer traces using phred. II. Error probabilities. Genome Res. 1998;8(3):186–94.

## Contributing
All contributions are welcome.

## Support
If you have any problem or suggestion please open an issue [here](https://github.com/dohalloran/SWC_BATCH_CHECK/issues).

## License 
GNU GENERAL PUBLIC LICENSE





