Add-Type -AssemblyName System.Windows.Forms

$conf = Import-LocalizedData -BaseDirectory ".\" -FileName "conf.psd1"

function centerForm {
  $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  $form.SetDesktopLocation(
    ($bounds.Width - $args[0].Width) / 2,
    ($bounds.Height - $args[0].Height) / 2
  )
}

function setMessage {
  $args[0].Text = $args[1]
  $args[2].Refresh()
  centerForm $args[2]
}

function mountDrives {
  $form.BackColor = "#FFFFFF"
  setMessage $textOverlay "Mounting network drives" $form
  
  $errors = @()
  $mounted = @()
  
  foreach ($drive in $conf.drives.GetEnumerator()) {
    Write-Host "Trying to mount - $($drive.Name): $($drive.Value)"
    
    $driveLetter = "$($drive.Name)"
    $drivePath = "$($drive.Value)"
    $letterAndPath = "$($driveLetter): \\$($conf.ip)\$($drivePath)"

    # try to mount the drive
    $process = (Start-Process -FilePath "C:\Windows\System32\net.exe" -ArgumentList "USE $($letterAndPath) /USER:$($conf.user) $($conf.pass) /PERSISTENT:No" -Passthru -WindowStyle "Hidden")
    $code = $process.ExitCode
    Wait-Process -id $process.ID -timeout 2 -ErrorAction SilentlyContinue -ErrorVariable timeoutErr
    
    if( $timeoutErr ){
      $code = 408
    }
    
    Write-Host "Mount status code - $($code)"
    
    # handle error
    if( $code -gt 0 ){
      $errors += ,"Couldn't mount $($letterAndPath) - Error Code $($code)"
    }else{
      $mounted += ,"Mounted $($letterAndPath)"
    }
  }
  
  if( $errors.length -gt 0 ){
    $errMsg  = ($errors -join "`r`n" | Out-String)
    $errMsg += "`r`n"
    $errMsg += "1) Try connecting again. `r`n"
    $errMsg += "2) Close. `r`n"
    $form.BackColor = "#FF0000"
    setMessage $textOverlay $errMsg $form
    
    $formKeyDownHandler = {
      switch -regex ( $_.KeyCode ){
        "01|NumPad1" {
          $form.Remove_KeyDown($formKeyDownHandler)
          formShowHandler
        }
        "02|NumPad2" {
          $form.Remove_KeyDown($formKeyDownHandler)
          $form.Close()
        }
      }
    }
    
    $form.Add_KeyDown($formKeyDownHandler)
  }else{
    $form.BackColor = "#00FF00"
    setMessage $textOverlay ($mounted -join "`r`n" | Out-String) $form
    
    Start-Sleep -s 2

    $form.Close()
  }
}

function formShowHandler {
  $form.Activate()
  
  $form.BackColor = "#FFFFFF"
  setMessage $textOverlay "Checking if network is up..." $form
  Start-Sleep -s 1
  
  $maxRetries = 10
  $retrycount = 0
  $completed = $false
  $done = $false

  while( -not $completed ){
    
    if( Test-Connection $conf.ip -count 1 -quiet ){
      $completed = $true
      
      $form.BackColor = "#00FF00"
      setMessage $textOverlay "Network is up" $form
      Start-Sleep -s 1
      
      mountDrives
    
    }else{
      if( $retrycount -ge $maxRetries ){
        $errorMsg  = "Tried to connect $($retrycount) times, there's `r`n"
        $errorMsg += "a problem with your network connection. `r`n"
        $errorMsg += "`r`n"
        $errorMsg += "1) Try connecting again. `r`n"
        $errorMsg += "2) Mount drives anyway. `r`n"
        $errorMsg += "3) Close. `r`n"
        
        $form.BackColor = "#FFFFFF"
        setMessage $textOverlay "$($errorMsg)" $form
        $completed = $true
        
        $formKeyDownHandler = {
          switch -regex ( $_.KeyCode ){
            "01|NumPad1" {
              $form.Remove_KeyDown($formKeyDownHandler)
              formShowHandler
            }
            "02|NumPad2" {
              $form.Remove_KeyDown($formKeyDownHandler)
              mountDrives
            }
            "03|NumPad3" {
              $form.Remove_KeyDown($formKeyDownHandler)
              $form.Close()
            }
          }
        }
        
        $form.Add_KeyDown($formKeyDownHandler)
      } else {
        $retrycount++
        $form.BackColor = "#FFFFFF"
        setMessage $textOverlay "$($retrycount) Checking for network connection." $form
        
        Start-Sleep -s 1
      }
    }
  }
}

$font = new-object System.Drawing.Font(
  "Arial",
  20,
  [System.Drawing.FontStyle]::Italic
)

$textOverlay = new-object System.Windows.Forms.Label
$textOverlay.AutoSize = $True
$textOverlay.BackColor = "Transparent"
$textOverlay.Padding = 20

$form = new-object System.Windows.Forms.Form
$form.Font = $font
$form.Text = "Loading Message"
$form.AutoSize = $True
$form.AutoSizeMode = "GrowAndShrink"
$form.SizeGripStyle = "Hide"
$form.BackColor = "#FFFFFF"
$form.opacity = 0.8
$form.controls.add($textOverlay)
$form.StartPosition = "CenterScreen"
$form.ShowInTaskbar = $False
$form.MinimizeBox = $False
$form.MaximizeBox = $False
$form.ControlBox = $False;
$form.FormBorderStyle = "None";
$form.Add_Shown({formShowHandler})
$form.ShowDialog()