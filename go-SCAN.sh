#!/bin/bash

urlscheme=http
port=80
domain=
curlflag=

usage() { echo -e "Usage: $0 -d domain [-s]\n  Select -s to use https to check host availability\n  Note that the SSL cert will not be validated" 1>&2; exit 1; }

while getopts "sd:" o; do
    case "${o}" in
        d)
            domain=${OPTARG}
            ;;
        s)
            urlscheme=https
            curlflag=-k
            port=443
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${domain}" ] ; then
    usage
fi

echo "domain = ${domain}"
echo "scheme = ${urlscheme}"

discovery(){
  hostalive $domain
  portscanner $domain
  nucleus
  screenshot $domain
  cleanup $domain
  cat ./$domain/$foldername/responsive-$(date +"%Y-%m-%d").txt | sort -u | while read -r line;
    do
        sleep 1
        dirsearcher $line </dev/null
        report $domain $line </dev/null
        echo "$line report generated"
        sleep 1
    done
}

cleanup(){
  cd ./$domain/$foldername/screenshots/
  rename 's/_/-/g' -- *
  cd $path
}

hostalive(){
  httpx -l ./$domain/$foldername/$domain.txt -o ./$domain/$foldername/responsive-$(date +"%Y-%m-%d").txt
}

nucleus(){
  nuclei -l ./$domain/$foldername/responsive-$(date +"%Y-%m-%d").txt -t miscellaneous/ -t technologies/ -t takeovers/ -t misconfiguration/ -t default-logins/ -t workflows/ -t vulnerabilities/ -t exposures/ -t cves/ -o ./$domain/$foldername/nuclei_output.txt
}

screenshot(){
    echo 
    echo "Taking a screenshot of assets of $domain"
    python3 ~/tools/webscreenshot/webscreenshot.py -o ./$domain/$foldername/screenshots/ -i ./$domain/$foldername/responsive-$(date +"%Y-%m-%d").txt --timeout=10 -m  --no-xserver
}

recon(){
  subfinder -d $domain -o ./$domain/$foldername/$domain.txt
  discovery $domain
  cat ./$domain/$foldername/$domain.txt | sort -u >> ./$domain/$foldername/$domain.txt
}

dirsearcher(){
  python3 ~/tools/dirsearch/dirsearch.py -e php,asp,aspx,jsp,html,zip,jar,sql -u $line
}

portscanner(){
  cat ./$domain/$foldername/$domain.txt | naabu -c 50 -p 80,3868,3366,8443,8080,9443,9091,3000,8000,5900,8081,6000,10000,8181,3306,5000,4000,8888,5432,15672,9999,161,4044,7077,4040,9000,8089,443,7447,7080,8880,8983,5673,7443 >> ./$domain/$foldername/portscan.txt
}


report(){
  if [[ $line != http://* ]]; then line2=$(echo $line | cut -c 9-); else line2=$(echo $line | cut -c 8-); fi
  touch ./$domain/$foldername/reports/$line2.html
  echo "<title> report for $line </title>" >> ./$domain/$foldername/reports/$line2.html
  echo "<html>" >> ./$domain/$foldername/reports/$line2.html
  echo "<head>" >> ./$domain/$foldername/reports/$line2.html
  echo "<link rel=\"stylesheet\" href=\"https://fonts.googleapis.com/css?family=Mina\" rel=\"stylesheet\">" >> ./$domain/$foldername/reports/$line2.html
  echo "</head>" >> ./$domain/$foldername/reports/$line2.html
  echo "<body><meta charset=\"utf-8\"> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"> <link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\"> <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js\"></script> <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js\"></script></body>" >> ./$domain/$foldername/reports/$line2.html
  echo "<div class=\"jumbotron text-center\"><h1> Recon Report for <a/href=\"$urlscheme://$line\">$line</a></h1>" >> ./$domain/$foldername/reports/$line2.html
  echo "$(date) </p></div>" >> ./$domain/$foldername/reports/$line2.html


  echo "   <div clsas=\"row\">" >> ./$domain/$foldername/reports/$line2.html
  echo "     <div class=\"col-sm-6\">" >> ./$domain/$foldername/reports/$line2.html
  echo "     <div style=\"font-family: 'Mina', serif;\"><h2>Dirsearch</h2></div>" >> ./$domain/$foldername/reports/$line2.html
  echo "<pre>" >> ./$domain/$foldername/reports/$line2.html
  cat ~/tools/dirsearch/reports/$line2/* | while read rline; do echo "$rline" >> ./$domain/$foldername/reports/$line2.html
  done
  echo "</pre>   </div>" >> ./$domain/$foldername/reports/$line2.html

  echo "     <div class=\"col-sm-6\">" >> ./$domain/$foldername/reports/$line2.html
  echo "<div style=\"font-family: 'Mina', serif;\"><h2>Screeshot</h2></div>" >> ./$domain/$foldername/reports/$line2.html
  echo "<pre>" >> ./$domain/$foldername/reports/$line2.html
  echo "Port 80                              Port 443" >> ./$domain/$foldername/reports/$line2.html
  echo "<img/src=\"../screenshots/http-$line-80.png\" style=\"max-width: 500px;\"> <img/src=\"../screenshots/https-$line-443.png\" style=\"max-width: 500px;\"> <br>" >> ./$domain/$foldername/reports/$line2.html
  echo "</pre>" >> ./$domain/$foldername/reports/$line2.html

  echo "<div style=\"font-family: 'Mina', serif;\"><h2>Dig Info</h2></div>" >> ./$domain/$foldername/reports/$line2.html
  echo "<pre>" >> ./$domain/$foldername/reports/$line2.html
  dig $line >> ./$domain/$foldername/reports/$line2.html
  echo "</pre>" >> ./$domain/$foldername/reports/$line2.html

  echo "<div style=\"font-family: 'Mina', serif;\"><h2>Host Info</h1></div>" >> ./$domain/$foldername/reports/$line2.html
  echo "<pre>" >> ./$domain/$foldername/reports/$line2.html
  host $line >> ./$domain/$foldername/reports/$line2.html
  echo "</pre>" >> ./$domain/$foldername/reports/$line2.html

  echo "<div style=\"font-family: 'Mina', serif;\"><h2>Response Header</h1></div>" >> ./$domain/$foldername/reports/$line2.html
  echo "<pre>" >> ./$domain/$foldername/reports/$line2.html
  curl -sSL -D - $line  -o /dev/null >> ./$domain/$foldername/reports/$line2.html
  echo "</pre>" >> ./$domain/$foldername/reports/$line2.html

  echo "<div style=\"font-family: 'Mina', serif;\"><h1>Portscan Results</h1></div>" >> ./$domain/$foldername/reports/$line2.html
  echo "<pre>" >> ./$domain/$foldername/reports/$line2.html
  naabu -c 25 -p 3868,3366,8443,8080,9443,9091,3000,8000,5900,8081,6000,10000,8181,3306,5000,4000,8888,5432,15672,9999,161,4044,7077,4040,9000,8089,443,7447,7080,8880,8983,5673,7443 -host $line2>> ./$domain/$foldername/reports/$line2.html
  echo "</pre></div>" >> ./$domain/$foldername/reports/$line2.html
  echo "</html>" >> ./$domain/$foldername/reports/$line2.html
}

artwork(){
  echo "  ██████   ██████        ███████  ██████  █████  ███    ██ 
██       ██    ██       ██      ██      ██   ██ ████   ██ 
██   ███ ██    ██ █████ ███████ ██      ███████ ██ ██  ██ 
██    ██ ██    ██            ██ ██      ██   ██ ██  ██ ██ 
 ██████   ██████        ███████  ██████ ██   ██ ██   ████ 
                                                          V 1.0.0 - h4ckologic
                                                          "                                                                                  
}
main(){
  clear
  artwork

  if [ -d "./$domain" ]
  then
    echo "This is a known target."
  else
    mkdir ./$domain
  fi
  mkdir ./$domain/$foldername
  mkdir ./$domain/$foldername/reports/
  mkdir ./$domain/$foldername/screenshots/
  touch ./$domain/$foldername/responsive-$(date +"%Y-%m-%d").txt

    recon $domain
}


path=$(pwd)
foldername=recon-$(date +"%Y-%m-%d")
main $domain