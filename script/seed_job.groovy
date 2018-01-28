import groovy.sql.Sql

def sql = Sql.newInstance("jdbc:mysql://mysql:3306/test", "root","admin", "com.mysql.jdbc.Driver")
sql.execute "select count(*) from Users"
