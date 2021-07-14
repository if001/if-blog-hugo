---
title: "Google ColaboratoryでGoogle driveをマウントする"
slug: "colaboratory-google-drive-mount"
tags: ["python"]
published: true
date: "2019-09-24T00:00:00+09:00"
---

久しぶりにColaboratory使ったらGoogle driveのマウントが簡単になってた。  

## before
認証

```python
!apt-get install -y -qq software-properties-common python-software-properties module-init-tools
!add-apt-repository -y ppa:alessandro-strada/ppa 2>&1 > /dev/null
!apt-get update -qq 2>&1 > /dev/null
!apt-get -y install -qq google-drive-ocamlfuse fuse
from google.colab import auth
auth.authenticate_user()
from oauth2client.client import GoogleCredentials
creds = GoogleCredentials.get_application_default()
import getpass
!google-drive-ocamlfuse -headless -id={creds.client_id} -secret={creds.client_secret} < /dev/null 2>&1 | grep URL
vcode = getpass.getpass()
!echo {vcode} | google-drive-ocamlfuse -headless -id={creds.client_id} -secret={creds.client_secret}
```

マウント

 ```python
!mkdir -p drive
!google-drive-ocamlfuse drive
 ```

## after

```python
from google.colab import drive
drive.mount('/gdrive')
```


