compdef _tsh tsh
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins commands hosts functions

global_args=('-l[Remote host login]' \
        '--login[Remote host login]' \
        '--proxy[SSH proxy address]' \
        '--user[SSH proxy user]' \
        '--ttl[Minutes to live for a SSH session]' \
        '-i[Identity file]' \
        '--identity[Identity file]' \
        '--cert-format[SSH certificate format]' \
        '--insecure[Do not verify servers certificate and host name. Use only in test environments]' \
        '--auth[Specify the type of authentication connector to use.]' \
        '--skip-version-check[Skip version checking between server and c lient.]' \
        '-d[Verbose logging to stdout]' \
        '--debug[Verbose logging to stdout]' \
        '-k[Controls how keys are handled. Valid values are (auto no yes only).]' \
        '--add-keys-to-agent[Controls how keys are handled. Valid values are (auto no yes only).]' \
        '--enable-escape-sequences[Enable support for SSH escape sequences. Type "~?" during an SSH session to list supported sequences. Default is enabled.]' \
        '--bind-addr[Override host:port used when opening a browser for cluster logins]' \
        '-J[SSH jumphost]' \
        '--jumphost[SSH jumphost]')

function _tsh {
    local line
    
    # completion area for subcommands
    function _commands {
        local -a commands

        commands=(
            'help:Show help.'
            'version:Print the tsh client and Proxy server versions for the current context.'
            'ssh:Run shell or execute a command on a remote SSH node.'
            'aws:Access AWS API.'
            'az:Access Azure API.'
            'gcloud:Access GCP API with the gcloud command.'
            'gsutil:Access Google Cloud Storage with the gsutil command.'
            'apps:View and control proxied applications.'
            # 'apps login:Retrieve short-lived certificate for an app.'
            # 'apps logout:Remove app certificate.'
            # 'apps config:Print app connection information.'
            'recordings:View and control session recordings.'
            # 'recordings :Export recorded desktop sessions to video.'
            'proxy:Run local TLS proxy allowing connecting to Teleport in single-port mode.'
            # 'proxy db:Start local TLS proxy for database connections when using Teleport in single-port mode.'
            # 'proxy app:Start local TLS proxy for app connection when using Teleport in single-port mode.'
            # 'proxy aws:Start local proxy for AWS access.'
            # 'proxy azure:Start local proxy for Azure access.'
            # 'proxy gcloud:Start local proxy for GCP access.'
            # 'proxy kube:Start local proxy for Kubernetes access.'
            'db:View and control proxied databases.'
            # 'db login:Retrieve credentials for a database.'
            # 'db logout:Remove database credentials.'
            # 'db env:Print environment variables for the configured database.'
            # 'db config:Print database connection information. Useful when configuring GUI clients.'
            # 'db connect:Connect to a database.'
            'join:Join the active SSH or Kubernetes session.'
            'play:Replay the recorded session (SSH, Kubernetes, App, DB).'
            'scp:Transfer files to a remote SSH node.'
            'ls:List remote SSH nodes.'
            'clusters:List available Teleport clusters.'
            'login:Log in to a cluster and retrieve the session certificate.'
            'logout:Delete a cluster certificate.'
            'status:Display the list of proxy servers and retrieved certificates.'
            'env:Print commands to set Teleport session environment variables.'
            'request:Manage access requests.'
            # 'request show:Show request details.'
            # 'request create:Create a new access request.'
            # 'request review:Review an access request.'
            # 'request search:Search for resources to request access to.'
            # 'request drop:Drop one more access requests from current identity.'
            'headless :Approve a headless authentication request.'
            'kubectl:Runs a kubectl command on a Kubernetes cluster.'
            'kube:Manage available Kubernetes clusters'
            # 'kube login:Login to a Kubernetes cluster.'
            # 'kube sessions:Get a list of active Kubernetes sessions.'
            # 'kube exec:Execute a command in a Kubernetes pod.'
            # 'kube join:Join an active Kubernetes session.'
            'mfa:Manage multi-factor authentication (MFA) devices.'
            # 'mfa add:Add a new MFA device.'
            # 'mfa rm:Remove a MFA device.'
            'config:Print OpenSSH configuration details.'
            'device enroll:Enroll this device as a trusted device. Requires Teleport Enterprise.'

        )
        _describe 'command' commands
    }

    # completion area for options/arguments
    
    _arguments $C \
        $global_args \
        "1: :_commands" \
        "*::arg:->args"

    case $line[1] in
        apps)
            _tsh_apps
        ;;
        proxy)
            _tsh_proxy
        ;;
        db)
            _tsh_db
        ;;
        ssh)
            _tsh_ssh
        ;;
        join)
            _tsh_join
        ;;
        play)
            _tsh_play
        ;;
        scp)
            _tsh_scp
        ;;
        ls)
            _tsh_ls
        ;;
        login)
            _tsh_login
        ;;
        logout)
            _tsh_logout
        ;;
        status)
            _tsh_status
        ;;
        env)
            _tsh_env
        ;;
        config)
            _tsh_config
        ;;
    esac

}

function _tsh_ssh {
    local state
    _arguments \
        $global_args \
        '-p[SSH port on a remote host]' \
        '--port[SSH port on a remote host]' \
        '-A[Forward agent to target node]' \
        '--forward-agent[Forward agent to target node]' \
        '-L[Forward localhost connections to remote server]' \
        '--forward[Forward localhost connections to remote server]' \
        '-D[Forward localhost connections to remote server using SOCKS5]' \
        '--dynamic-forward[Forward localhost connections to remote server using SOCKS5]' \
        '--local[Execute command on localhost after connecting to SSH node]' \
        '-t[Allocate TTY]' \
        '--tty[Allocate TTY]' \
        '--cluster[Specify the Teleport cluster to connect]' \
        '-o[OpenSSH options in the format used in the configuration file]' \
        '--option[OpenSSH options in the format used in the configuration file]' \
        '-N[Don'"'"'t execute remote command]' \
        '--no-remote-exec[Don'"'"'t execute remote command]' \
        '1:host:->userhost' \
        '*::arg:->args'

    case "$state" in 
    userhost)
        if compset -P '*@'; then
            _wanted hosts expl 'remote host name' _tsh_hosts && ret=0
        elif compset -S '@*'; then
            _wanted users expl 'login name' _tsh_users -S '' && ret=0
        else
            if (( $+opt_args[-l] )); then
                tmp=()
            else
                tmp=( 'users:login name:_tsh_users -qS@' )
            fi
            _alternative \
                'hosts:remote host name:_tsh_hosts' \
                "$tmp[@]" && ret=0
        fi 
    esac
}
function _tsh_join {
    _arguments $C \
        $global_args \
        '--cluster[Specify the Teleport cluster to connect]' \
        "*::arg:->args"
}
function _tsh_play {
    _arguments $C \
        $global_args \
        '--cluster[Specify the Teleport cluster to connect]' \
        "*::arg:->args"
}
function _tsh_scp {
    local state
    _arguments $C \
        $global_args \
        '--cluster[Specify the Teleport cluster to connect]' \
        '-r[Recursive copy of subdirectories]' \
        '--recursive[Recursive copy of subdirectories]' \
        '-p[Preserves access and modification times from the original file]' \
        '--preserve[Preserves access and modification times from the original file]' \
        '-q[Quiet mode]' \
        '--quiet[Quiet mode]' \
        '*:files:->file'

    case "$state" in
    file)
        if compset -P 1 '[^./][^/]#:'; then
            _remote_files -- tsh ssh ${(kv)~opt_args[(I)-[FP1246]]/-P/-p} && ret=0
        elif compset -P 1 '*@'; then
            suf=( -S '' )
            compset -S ':*' || suf=( -r: -S: )
            _wanted hosts expl 'remote host name' _tsh_hosts $suf && ret=0
        else
            _alternative \
                'files:: _files' \
                'hosts:remote host name:_tsh_hosts -r: -S:' \
                'users:user:_tsh_users -qS@' && ret=0
        fi
        ;;
    esac
}


function _tsh_apps {
    local commands=(
        "ls:List available applications." \
        "login:Retrieve short-lived certificate for an app." \
        "logout:Remove app certificate." \
        "config:Print app connection information."
    )

    _describe 'command' commands
    _arguments $c \
        $global_args \
      "-l[Remote host login]" \
      "--login[Remote host login]" \
      "--proxy[Teleport proxy address]" \
      "--user[Teleport user, defaults to current local user]" \
      "--ttl[Minutes to live for a session]" \
      "-i[Identity file]" \
      "--identity[Identity file]" \
      "--cert-format[SSH certificate format]" \
      "--no-insecure[Do not verify server's certificate and host name. Use only in test environments]" \
      "--auth[Specify the name of authentication connector to use.]" \
      "--no-skip-version-check[Skip version checking between server and client.]" \
      "-d[Verbose logging to stdout]" \
      "--no-debug[Verbose logging to stdout]" \
      "--add-keys-to-agent[Controls how keys are handled. Valid values are (auto no yes only).]" \
      "-k[Controls how keys are handled. Valid values are (auto no yes only).]" \
      "--no-enable-escape-sequences[Enable support for SSH escape sequences. Type '~?' during an SSH session to list supported sequences. Default is enabled.]" \
      "--bind-addr[Override host:port used when opening a browser for cluster logins]" \
      "--mfa-mode[Preferred mode for MFA and Passwordless assertions (auto, cross-platform, platform, otp)]" \
      "--no-headless[Use headless login. Shorthand for --auth=headless.]" \
      "--mlock[Determines whether process memory will be locked and whether failure to do so will be accepted (off, auto, best_effort, strict).]" \
      "--piv-slot[Specify a PIV slot key to use for Hardware Key support instead of the default. Ex: "9d"]" \
      "-J[SSH jumphost]" \
      "--jumphost[SSH jumphost]" 

}

function _tsh_proxy {
    local commands=(
        "ssh:Start local TLS proxy for ssh connections when using Teleport in single-port mode." \
        "db:Start local TLS proxy for database connections when using Teleport in single-port mode." \
        "app:Start local TLS proxy for app connection when using Teleport in single-port mode." \
        "aws:Start local proxy for AWS access." \
        "azure:Start local proxy for Azure access." \
        "gcloud: local proxy for GCP access." \
        "kube:Start local proxy for Kubernetes access." 
    )

    _describe 'command' commands
    _arguments $C \
        $global_args \
       "-l[Remote host login]" \
       "--login[Remote host login]" \
       "--proxy[Teleport proxy address]" \
       "--user[Teleport user, defaults to current local user]" \
       "--ttl[Minutes to live for a session]" \
       "-i[Identity file]" \
       "--identity[Identity file]" \
       "--cert-format[SSH certificate format]" \
       "--no-insecure[Do not verify server's certificate and host name. Use only in test environments]" \
       "--auth[Specify the name of authentication connector to use.]" \
       "--no-skip-version-check[Skip version checking between server and client.]" \
       "-d[Verbose logging to stdout]" \
       "--no-debug[Verbose logging to stdout]" \
       "--k[Controls how keys are handled. Valid values are auto no yes only.]" \
       "--add-keys-to-agent[Controls how keys are handled. Valid values are auto no yes only.]" \
       "--no-enable-escape-sequences  Enable support for SSH escape sequences. Type '~?' during an SSH session to list supported sequences. Default is enabled." \
       "--bind-addr[Override host:port used when opening a browser for cluster logins]" \
       "--mfa-mode[Preferred mode for MFA and Passwordless assertions (auto, cross-platform, platform, otp)]" \
       "--no-headless[Use headless login. Shorthand for --auth=headless.]" \
       "--mlock[Determines whether process memory will be locked and whether failure to do so will be accepted (off, auto, best_effort, strict).]" \
       "--piv-slot[Specify a PIV slot key to use for Hardware Key support instead of the default. Ex: "9d"]" \
       "-J[SSH jumphost]" \
       "--jumphost[SSH jumphost]" 
}

function _tsh_db {
    local commands=(
        "ls:List all available databases." \
        "login:Retrieve credentials for a database." \
        "logout:Remove database credentials." \
        "env:Print environment variables for the configured database." \
        "config:Print database connection information. Useful when configuring GUI clients." \
        "connect:Connect to a database." 

    )

    _describe 'command' commands
    _arguments $C \
        $global_args \
      "-l[Remote host login]" \
      "--login[Remote host login]" \
      "--proxy[Teleport proxy address]" \
      "--user[Teleport user, defaults to current local user]" \
      "--ttl[Minutes to live for a session]" \
      "-i[Identity file]" \
      "--identity[Identity file]" \
      "--cert-format[SSH certificate format]" \
      "--no-insecure[Do not verify server's certificate and host name. Use only in test environments]" \
      "--auth[Specify the name of authentication connector to use.]" \
      "--no-skip-version-check[Skip version checking between server and client.]" \
      "-d[Verbose logging to stdout]" \
      "--no-debug[Verbose logging to stdout]" \
      "-k[Controls how keys are handled. Valid values are (auto no yes only).]" \
      "--add-keys-to-agent[Controls how keys are handled. Valid values are (auto no yes only).]" \
      "--no-enable-escape-sequences[Enable support for SSH escape sequences. Type '~?' during an SSH session to list supported sequences. Default is enabled.]" \
      "--bind-addr[Override host:port used when opening a browser for cluster logins]" \
      "--mfa-mode[Preferred mode for MFA and Passwordless assertions (auto, cross-platform, platform, otp)]" \
      "--no-headless[Use headless login. Shorthand for --auth=headless.]" \
      "--mlock[Determines whether process memory will be locked and whether failure to do so will be accepted (off, auto, best_effort, strict).]" \
      "--piv-slot[Specify a PIV slot key to use for Hardware Key support instead of the default. Ex: "9d"]" \
      "-J[SSH jumphost]" \
      "--jumphost[SSH jumphost]" \
      "-c[Specify the Teleport cluster to connect]" \
      "--cluster[Specify the Teleport cluster to connect]"
}

function _tsh_ls {
    _arguments $C \
        $global_args \
        '--cluster[Specify the Teleport cluster to connect]' \
        "-v[One-line output (for text format), including node UUIDs]" \
        "--verbose[One-line output (for text format), including node UUIDs]" \
        "-f[Format output (text, json, names)]" \
        "--format[Format output (text, json, names)]" \
        "*::arg:->args"
}
function _tsh_login {
    _arguments $C \
        $global_args \
        "-o[Identity output]" \
        "--out[Identity output]" \
        "--format[Identity format: file, openssh (for OpenSSH compatibility) or kubernetes (for kubeconfig)]" \
        "--overwrite[Whether to overwrite the existing identity file.]" \
        "--request-roles[Request one or more extra roles]" \
        "--request-reason[Reason for requesting additional roles]" \
        "--request-reviewers[Suggested reviewers for role request]" \
        "--request-nowait[Finish without waiting for request resolution]" \
        "--request-id[Login with the roles requested in the given request]" \
        "--browser[Set to 'none' to suppress browser opening on login]" \
        "--kube-cluster[Name of the Kubernetes cluster to login to]" \
        "*::arg:->args"
}
function _tsh_logout {
    _arguments $C \
        $global_args \
        "*::arg:->args"
}
function _tsh_status {
    _arguments $C \
        $global_args \
        "*::arg:->args"
}
function _tsh_env {
    _arguments $C \
        $global_args \
        '--unset[Print commands to clear Teleport session environment variables]' \
        "*::arg:->args"
}
function _tsh_config {
    _arguments $C \
        $global_args \
        "*::arg:->args"
}
function _tsh_hosts {
    local expl
    local -a result
    if ( [[ ${(P)+tsh_hosts} -eq 0 ]] || _cache_invalid tsh_hosts ) \
        && ! _retrieve_cache tsh_hosts; then
        tsh login > /dev/null 2>&1
        result=($(tsh ls --format=names))
        _store_cache tsh_hosts result
    fi
    _description hosts expl host
    _wanted hosts expl host compadd "$expl[@]" - "$result[@]"
}

function _tsh_users () {
    zstyle ":completion:*:tsh:*:users" users $(tsh status|grep Logins|sed -e 's/ Logins:[ \t]*//' -e 's/,//')
    _combination -s '[:@]' my-accounts users-hosts users "$@"
}
