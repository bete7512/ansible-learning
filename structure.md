ansible-deployment/
├── ansible.cfg                 # Ansible configuration file
├── inventories/               # Environment-specific inventories
│   ├── production/
│   │   ├── hosts              # Production servers
│   │   └── group_vars/
│   │       ├── all.yml        # Variables for all groups
│   │       └── webservers.yml # Variables for webserver group
│   └── staging/
│       ├── hosts              # Staging servers
│       └── group_vars/
│           └── all.yml
├── playbooks/                 # Main playbooks
│   ├── site.yml              # Master playbook
│   ├── deploy-app.yml        # Application deployment
│   └── setup-infrastructure.yml # Infrastructure setup
├── roles/                     # Reusable roles
│   ├── common/               # Common server setup
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── vars/main.yml
│   │   └── templates/
│   ├── docker/               # Docker installation & setup
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   └── defaults/main.yml
│   ├── nginx/                # Nginx configuration
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/
│   │   │   └── nginx.conf.j2
│   │   └── defaults/main.yml
│   └── golang-app/           # Go application deployment
│       ├── tasks/main.yml
│       ├── handlers/main.yml
│       ├── files/
│       │   ├── main.go
│       │   └── Dockerfile
│       └── defaults/main.yml
├── group_vars/               # Global group variables
│   └── all.yml
└── host_vars/                # Host-specific variables
    └── userapi.yml