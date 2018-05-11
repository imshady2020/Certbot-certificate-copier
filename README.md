# Certbot Certificate Copier

If you run Certbot in “manual” mode to create LetsEncrypt site certificates on your macOS computer that you must then
install on a server (for example, one that uses cPanel), this AppleScript application makes copying the certificate and
private key files on to the clipboard quick and easy.

Certbot stores the certificate and private key files in a folder that requires administrator privileges to access. 
This makes it somewhat tedious when you need copy their contents onto the clipboard. 
This AppleScript simplifies this process by copying the site’s certificate to the clipboard, and then, when you tell it to,
it does the same for the private key. 
If you have more than one site, you will be asked to choose one before the certificate will be copied.

## Running the App
1. Open/Run the app
2. enter an administrator’s password
3. if you have more than one site you must choose the site you want

    - if you have only one site, there’s nothing to choose
4. the next dialogue you see should be telling you that the certificate has been copied to the clipboard

    - now that it’s on the clipboard, do whatever you need to do with the certificate (for example, paste it into the appropriate
cPanel configuration page)
6. click **Continue**
7. the last dialogue you’ll see should now be telling you that the private key has been copied to the clipboard

    - do whatever you need to do with the private key
9. click **Quit** or **Clear Clipboard and Quit** (remember, to protect the private key!)

## Assumptions
- Certbot site folders are stored under `/etc/letsencrypt/live/`
- the certificate file name is `cert.pem`
- the private key file name is `privkey.pem`

## Requirements
- macOS 10.10 (Yosemite) or later
- manually created Certbot site certificates stored at the folder named above
    - for installation and usage instructions on Certbot, see https://certbot.eff.org
    
## Comments
- all comments welcome!
