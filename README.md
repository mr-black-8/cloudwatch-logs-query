CloudWatch Logs Query
---

Run Insights query on specific log group & search results

### Dependencies:
This script requires the following dependencies to be installed:

fzf (https://github.com/junegunn/fzf#installation)

jq (https://stedolan.github.io/jq/download/)

aws-cli (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)


### Setup:

Mark `cw-logs.sh` file as executable:
```
$ chmod +x cw-logs.sh
```

Create alias in your prefered .*rc file:
```
alias cwlogs='~/<path to cloudwatch-logs-query>/cw-logs.sh'
```

Run the help command for details on available flags:
```
cwlogs -h
```

### Customise Layout
You may wish to customise the fzf preview to better suit the dimensions of your prefered terminal layout. This can be done by chaning the value given to the `--preview-window` flag on the final line of the script.

```
--preview-window '<position>:<size>:wrap'
```
Where `<position>` is: `up`, `right`, `down`, or `left`

And `<size>` is a percentage of the terminal window to use.

For example:
```
--preview-window 'up:70%:wrap'
```