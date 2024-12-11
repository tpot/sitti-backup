HOST=ubuntu@ec2-13-211-73-154.ap-southeast-2.compute.amazonaws.com

mysqldump.sql.gz:
	rsync -av $(HOST):mysqldump.sql.gz .
