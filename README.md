# Linux_notes

All the notes I created while I was studing Linux Administration on one place.


# WSL users must do this command after installation.
```bash 
echo "kernel.unprivileged_userns_clone=1" | sudo tee /etc/sysctl.d/99-podman.conf
sudo sysctl --system
```

