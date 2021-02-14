```
 ██████   ██████        ███████  ██████  █████  ███    ██ 
██       ██    ██       ██      ██      ██   ██ ████   ██ 
██   ███ ██    ██ █████ ███████ ██      ███████ ██ ██  ██ 
██    ██ ██    ██            ██ ██      ██   ██ ██  ██ ██ 
 ██████   ██████        ███████  ██████ ██   ██ ██   ████ 
                                                          V 1.0.0 - h4ckologic
```
### A simple bash script to perform recon using existing (mostly) go based tools. 

### Tools Used  
- Project Discovery's Nuclei , Httpx , Naabu , Subfinder (https://github.com/projectdiscovery)
- Dirsearch (https://github.com/maurosoria/dirsearch)
- Webscreenshot (https://github.com/maaaaz/webscreenshot)
- Lazyrecon (https://github.com/nahamsec/lazyrecon)

Usage : ./goscan.sh -d domain

### Workflow
![Workflow](https://i.ibb.co/2Y79Qk9/Screen-Shot-2021-02-14-at-2-25-20-PM.png)

### Directory Structure of all the information gathered by the tool.
Date wise recon folder
 - domain_name.txt → contains all the domains
 - nuclei_output.txt → All nuclei output
 - portscan.txt → portscan result
 - reports/ → domain wise report 
 - responsive_date.txt → all responsive domains on that day
 - screenshots → domain-wise screen captures

### Reporting
A well formatted report is generated domain wise in the reports folder containing all the relevant information regarding that domain.
