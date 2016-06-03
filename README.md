<img src="/images/icon.png" alt="đ" width="64" height="64"> smileywallet
----------------------------------

[![download](/images/Download_on_the_App_Store_Badge_US-UK_135x40.png)]
(https://itunes.apple.com/app/smileywallet/id951731776)

**smileycoin done right**

the simplest and most secure smileycoin wallet on any platform 

**features:**

- the first real smileycoin client for iOS 
- doesn't rely on any server or web service 
- single backup phrase that works forever 
- private keys never leave your device 
- "simplified payment verification" for fast mobile performance 
- import password protected paper wallets 
- "payment protocol" payee identity certification
- open source

**security:**

doughcoin represents a major step forward in smileycoin wallet security. It is
designed to be secure against malware, security issues with other apps, and
even physical theft. It makes full use of the security features provided by iOS,
including AES hardware encryption, app sandboxing and data protection, code
signing, and keychain services.

**reliability:**

Unlike other iOS smileycoin wallets, smileywallet is a real smileycoin client. There
are no external web services or servers to get hacked or go down, so you always
have access to your money. It uses "simplified payment verification" or
[SPV](https://en.bitcoin.it/wiki/Thin_Client_Security#Header-Only_Clients) mode
to retrive data directly from the smileycoin network with the fast performance you
need in a mobile environment.

**convenience:**

Your entire wallet is backed up with a single convenient backup phrase that
will work forever. If your device is ever lost or broken, use your backup
phrase to restore your balance and transaction history on another device. This
is possible because smileywallet is a 
[BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)
"deterministic" wallet, meaning that all your smileycoin addresses and private
keys are generated from a single "seed".

smileywallet is open source and available under the terms of the MIT license.
Source code is available at https://github.com/peritus/smileywallet

**WARNING:** installation on jailbroken devices is strongly discouraged

Any jailbreak app can grant itself access to every other app's keychain data
and rob you by self-signing as described [here](http://www.saurik.com/id/8)
and including `<key>application-identifier</key><string>*</string>` in its
.entitlements file.
