# Useful tasks with the shell.


### Find (and destroy) EC2 EBS snapshots with a certain tag

```ruby
to_be_deleted = aws().snapshots.select { |s| s.tags.fetch("ebs_lvm:lineage", "").include?("kafka") }
to_be_deleted.each { |s| s.destroy }
```
