HOST=ubuntu@ec2-13-211-73-154.ap-southeast-2.compute.amazonaws.com

default:
	@echo 'This Makefile not intended to be run with a default target' && exit 1

mysqldump:
	ssh $(HOST) 'sudo mysqldump --protocol=socket -S /var/run/mysqld/mysqld.sock --all-databases | gzip -9c > foo'

varhtml:
	rsync -av $(HOST):/var/www/html/ var-www-html/

mysqldump.sql.gz:
	rsync -av $(HOST):mysqldump.sql.gz .
