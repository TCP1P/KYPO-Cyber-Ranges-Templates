# panduan pembuatan challenge ctf
- buat folder dengan nama challenge mengikuti format tcp1p ctf special ramadhan 2025 nanti ta buatin reponya buat ngumpul

# panduan pembuatan lab
- install https://developer.hashicorp.com/vagrant/install
- install https://www.virtualbox.org/
- install https://gitlab.ics.muni.cz/muni-kypo-csc/cyber-sandbox-creator
- buat topology.yml di folder git kalian, ex topology.yml, contoh bisa di cek di https://gitlab.ics.muni.cz/muni-kypo-csc/cyber-sandbox-creator/-/tree/master/topologies?ref_type=heads
- jalankan `create-sandbox .\topology.yml -o .`
- buat README.md, game_design.md, training.json . Referemsi: https://gitlab.ics.muni.cz/muni-kypo-trainings/games/junior-hacker/
  - kalian bisa cek TYPE dan juga challenge definition disini: https://docs.crp.kypo.muni.cz/user-guide-basic/training-agenda/training-agenda-overview/
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