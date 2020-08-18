import ldap
conn = ldap.initialize('ldap://ldap-test.move.systems')
user = 'uid={},ou=people,dc=move,dc=systems'.format('foobar')
password = '12345678x'
try:
    conn.bind_s(user, password)
except ldap.INVALID_CREDENTIALS:
    print('compoter says nooooooooo')
