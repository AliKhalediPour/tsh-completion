## TSH Auto Completion

### Install
Copy the completion file to the desired directory like: <br>
`cp completion ~/.tsh`
<br>

source to the file:
<br>
`source <$(cat ~/.tsh/completion)`

You can append the above command to the end of the ~/.zshrc file to run automatically after login 
<br>
`echo "source <$(cat ~/.tsh/completion)" >> ~/.zshrc`
