$env:TEST_CONNECTION_STRING = 'Server=(local)\SQL2014;Database=MyDatabase_test;User ID=sa;Password=Password12!'
cmd /c where sqlpackage
if($LastExitCode -ne 0) { $host.SetShouldExit($LastExitCode) }
# deploy .dacpac package to local SQL Server instance for integration testing
#  - '"C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync -source:dbDacFx="%appveyor_build_folder%\MyDatabase\bin\Debug\MyDatabase.dacpac" -dest:dbDacFx="%TEST_CONNECTION_STRING%",dacpacAction=Deploy,CreateNewDatabase=True'
sqlpackage /Action:Publish /SourceFile:"$env:appveyor_build_folder\MyDatabase\bin\Debug\MyDatabase.dacpac" /TargetConnectionString:"$env:TEST_CONNECTION_STRING"
if($LastExitCode -ne 0) { $host.SetShouldExit($LastExitCode) }
$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = $env:TEST_CONNECTION_STRING
$conn.Open()
$cmd = New-Object System.Data.SqlClient.SqlCommand("SELECT * FROM information_schema.tables", $conn)
$reader = $cmd.ExecuteReader()
while($reader.Read())
{
  Write-Host "Table: $($reader["table_name"])"
}
$conn.Close()
if($LastExitCode -ne 0) { $host.SetShouldExit($LastExitCode) }
