# Deploy all sysadmins on the kvm Server

# generate password 

	pip3 install passlib
	
	python3 -c "from passlib.hash import sha512_crypt; import getpass; print(sha512_crypt.using(rounds=5000).hash(getpass.getpass()))"
	
	
# remove user

Remove all keys from dict and add `remove: True` 
