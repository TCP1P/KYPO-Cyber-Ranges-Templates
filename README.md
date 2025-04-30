# panduan pembuatan challenge ctf
- buat folder dengan nama challenge mengikuti format tcp1p ctf special ramadhan 2025 nanti ta buatin reponya buat ngumpul

# panduan pembuatan lab
- install https://developer.hashicorp.com/vagrant/install
- install https://www.virtualbox.org/
- install https://gitlab.ics.muni.cz/muni-kypo-csc/cyber-sandbox-creator
- buat topology.yml di folder git kalian, ex topology.yml:
```yaml
name: junior-hacker-sandbox

hosts:
  - name: attacker
    base_box: 
      image: kalilinux/rolling
      mgmt_user: debian
    flavor: csirtmu.tiny1x2

  - name: server
    base_box:
      image: debian/bookworm64
      mgmt_user: debian
    flavor: csirtmu.tiny1x2

  - name: client
    base_box: 
      image: debian/bookworm64
      mgmt_user: debian
    flavor: csirtmu.tiny1x2

routers:
  - name: router
    base_box:
      image: debian/bookworm64
      mgmt_user: debian
    flavor: csirtmu.tiny1x2

wan:
  name: internet-connection
  cidr: 100.100.100.0/24

networks:
  - name: target-switch
    cidr: 10.1.26.0/24
    accessible_by_user: False
  - name: attacker-switch
    cidr: 10.1.27.0/24

net_mappings:
    - host: attacker
      network: attacker-switch
      ip: 10.1.27.23

    - host: server
      network: target-switch
      ip: 10.1.26.9

    - host: client
      network: target-switch
      ip: 10.1.26.4

router_mappings:
    - router: router
      network: target-switch
      ip: 10.1.26.1
    - router: router
      network: attacker-switch
      ip: 10.1.27.1

groups: []
```
contoh lain bisa di cek di https://gitlab.ics.muni.cz/muni-kypo-csc/cyber-sandbox-creator/-/tree/master/topologies?ref_type=heads
note: debiannya pake versi lawas, jadi pass install package kadang nda work, bisa diganti ke versi terbaru seperti contoh diatas
- jalankan `create-sandbox .\topology.yml -o .`
- buat README.md, game_design.md, training.json . Referemsi: https://gitlab.ics.muni.cz/muni-kypo-trainings/games/junior-hacker/
- update preconfig/roles/interface/tasks/main.yml menjadi:
```yaml
- name: sanity check
  fail:
      msg: '{{ interface_sanity_check_msg }}'
  when: interface_sanity_check_msg | length > 0

- include_tasks: clean.yml
  when: interface_clean is defined and interface_clean

- include_tasks: interface.yml

```
- tambahkan config.vm.boot_timeout = 9999 ke Vagrant.configure agar tidak timeout sama booting
- jalankan vm menggunakan `manage-sandbox build -v`

# lain-lain
- jika mau menggunakan ansible galaxy bisa tambahkan 
```v
      ansible.galaxy_role_file = "provisioning/requirements.yml"
      ansible.galaxy_roles_path = "provisioning/roles"
      ansible.galaxy_command = "sudo ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path} --force"
```
di vm.provision ansible_local di konfigurasi setiap vm di vagrant.
Buat requirements.yml untuk roles yang ingin kamu gunakan seperti contoh ini https://gitlab.ics.muni.cz/muni-kypo-trainings/games/junior-hacker/-/blob/master/provisioning/requirements.yml?ref_type=heads .
Dan terakhir kalian bisa tambahkan configurasi setiap vm kalian contohnya seperti berikut https://gitlab.ics.muni.cz/muni-kypo-trainings/games/junior-hacker/-/blob/master/provisioning/playbook.yml?ref_type=heads

- untuk mendelete vm kalian bisa menggunakan `vagrant destroy -f`