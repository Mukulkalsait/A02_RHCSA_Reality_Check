<!-- Y:  /shared/authorized_keys -->

 # What is authorized_keys?
    - It is the file where SSH server checks which public keys are allowed to login.
    - Normally located at: ~/.ssh/authorized_keys

 # Why /shared/authorized_keys?

 ## Because you have many containers, each built from different Linux distros. Instead of putting your public key in every container manually we:

    - keep ONE master authorized_keys file in /shared
    - mount or softlink it to all containers
    - so whenever you update your SSH key,
    - all containers automatically get the updated version


  ### Benefits
    - Huge simplification
    - No need to rebuild images for adding keys.
    - Consistency
    - Same key set everywhere.
    - Automation
