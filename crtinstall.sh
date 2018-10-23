#!/bin/bash 
#
#to prevent errors
#set -e
#set -o nounset

NGINX_BIN="/usr/sbin/nginx"
NGINX_CONF_DIR="/etc/nginx/conf.d"
SSL_DIR="/etc/ssl"

print_separator() {
    lines=$(tput lines)
    printf "%0.s=" $(seq 1 "$lines")
    printf "\n"
}
reload_nginx() {
    if sudo $NGINX_BIN -s reload 2>&1 | tee $1 ; then
        sleep 3 
	return 0
    else
        return 1
    fi

}
declare -a txt_files=()
declare -a crt_files=()
fname=""
#path to source folder
src_path=$(pwd)
#change to path with zip and txt files
cert_path="${1:-certs}"

print_separator
printf "Script will take files from %s folder, Are you sure?\n" "$cert_path"
while true; do
read answer
case $answer in 
    [Yy]* ) print_separator; printf "Working...\n"; break;;
    [Nn]* ) exit 1;;
    * ) echo "Please answer yes or no"
esac
done

#change to the source files directory, extract it and populate arrays
cd "$cert_path"
for file in *.zip
do
    unzip -ojq "$file"
    crt_files=("${crt_files[@]}" "${file}")
done
for file in *.txt
do
    txt_files=("${txt_files[@]}" "$file")
done


#check for errors
if [[ "${#crt_files[@]}" != "${#txt_files[@]}" ]]; then
    printf "Error:\n crt files number is %s, txt files number %s\n" "${#crt_files[@]}" "${#txt_files[@]}"
    while true; do
        read answer
        case $answer in 
            [Yy]* ) print_separator; printf "Continue...\n"; break;;
            [Nn]* ) exit 1;;
            * ) echo "Please answer yes or no"
        esac
    done
fi

print_separator
sites_count="${#crt_files[@]}"
printf "Number of sites is %s\n" "$sites_count"
print_separator

tmp_dir=$(mktemp -d)
if [ -z tmp_dir ]; then
    echo "Could not create tmp_dir"
    exit 1
fi
printf "Created tmp_dir: $tmp_dir\n"
mkdir -p "$tmp_dir/ssl";
mkdir -p "$tmp_dir/nginx/conf.d";

print_separator
printf "Processing certificates\n"
print_separator
for ((i=0; i<${#crt_files[@]}; i++)); do
    declare -a errors
    #cut txt files extension
    fname="${txt_files[$i]%.*}"
    site="${crt_files[$i]%.*}"
    domain="${site##*_}"
    site="${site%_*}"
    site_name=$(echo ${site}.${domain} | sed 's/www_//' )

    printf "Site name is: %s\n" "$site_name"

    #extract key part from txt files
    perl -ne 'print if /-----BEGIN RSA PRIVATE KEY-----/ .. /-----END RSA PRIVATE KEY-----/' < "${fname}.txt" > "${site_name}.key"

    #join site cert and ca-bundlels 
    cat "${site}_${domain}.crt" "${site}_${domain}.ca-bundle" > "${site_name}.crt"

    #get, comparison and print cert and key hash
    
    

    CRT=$(openssl x509 -noout -modulus -in "${site_name}.crt" | openssl md5)
    KEY=$(openssl rsa -noout -modulus -in "${site_name}.key" | openssl md5)

   

    #If decalring an array and then accessing it while it is empty, then it gives an error,
    #until this syntax is used
    declare -a errors=()
     #if cert and key cert is equal - move them to dest folder
    if [ "$CRT" == "$KEY" ]
    then   
        printf "MD5 Hashes are equal. Creatind directories. Moving files to the tmp_dir\n"
        #certs
        mkdir -p "$tmp_dir/ssl/${site_name}"
        mv "${site_name}.key" "$tmp_dir/ssl/${site_name}/${site_name}.key"
        mv "${site_name}.crt" "$tmp_dir/ssl/${site_name}/${site_name}.crt"
        #nginx conf
        sed -e "s/site.domain/${site_name}/g" -e "s/site_domain/${site_name}/g" "${src_path}/site.domain.conf" > "${src_path}/${site_name}.conf"
        mv "${src_path}/${site_name}.conf" "$tmp_dir/nginx/conf.d/"
        print_separator
        
        printf "Checking %s:\n" "$site_name"
        if curl -sf "http://${site_name}" 2>&1 > "$tmp_dir/curl.log"; then
            printf "HTTP OK. Site is accessible\n"
            #copy files to the /etc directory
            sudo cp -ir "$tmp_dir/ssl/${site_name}" "$SSL_DIR"
            sudo cp -i "$tmp_dir/nginx/conf.d/${site_name}.conf" "$NGINX_CONF_DIR"
            #check nginx conf files
            if sudo $NGINX_BIN -t; then
                while true; do
                    read -p "Nginx syntax check is ok, RELOAD NGINX?" answer
                    case $answer in
                        [Yy]* ) reload_nginx;break;;
                        [Nn]* ) break;;
                        * ) echo "Please answer Yes or No";;
                    esac
                done
                if reload_nginx "$tmp_dir/nginx.log"; then
                    printf "Nginx restart is ok, checking HTPPS access:\n"
                    if curl -sf "https://${site_name}" 2>&1 > "$tmp_dir/curl.log"; then
                        printf "HTPPS OK. Site work is completed\n"
                    else
                        printf "ERROR, HTTPS is not accessible, below is curl log file\n"
                        cat "$tmp_dir/curl.log"
                    fi
                else
                    printf "ERROR: Nginx restart is failed, below is nginx log\n"
                    cat "$tmp_dir/nginx.log"
                fi
            else
                printf "ERROR: Nginx syntax check is failed\n"
            fi
        fi
    else
        err_str="site $site_name, crt md5: $CRT, key md5: $KEY"
        errors=("${errors[@]}" "$err_str")
    fi
done

if [ "${#errors[@]}" -eq 0 ]; then
    printf "OK: All sites processed\n"
else
    printf "ERROR: %s site certs are invalid:", "${#errors[@]}"
    for err in "${errors[@]}"
    do
        printf "%s" "$err"
        printf "\n"
        print_separator
    done
fi
printf "Files are located in %s\n" "$tmp_dir"

#remove certs, tmp_dir
# rm -ri "$tmp_dir"
# rm -ri "$cert_path"




