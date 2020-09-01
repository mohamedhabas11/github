import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_system_info(host):
    assert host.system_info.type == 'linux'
    assert host.system_info.distribution == 'ubuntu'
    # assert host.system_info.release == '16.04'
    # assert host.system_info.codename == 'xenial'
