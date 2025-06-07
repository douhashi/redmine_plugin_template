# Redmine Plugin Template Repository

A ready-to-use template repository for creating new Redmine plugins with modern development practices and comprehensive tooling.

## Overview

This template repository provides a complete development environment and scaffolding for Redmine plugin creation. Use this as a starting point to generate new plugin repositories with:

- **Pre-configured Plugin Structure** - Standard Redmine plugin architecture with MVC pattern
- **Complete Development Environment** - Everything needed to start plugin development immediately
- **Best Practices Implementation** - Security, internationalization, and Redmine integration patterns
- **Comprehensive Documentation** - Detailed guides for plugin development workflows
- **Automated Setup Tools** - Scripts to customize the template for your specific plugin

## What This Template Provides

### Development Environment
- **Complete Plugin Structure** - Ready-to-use MVC architecture following Redmine conventions
- **Sample Implementation** - Working CRUD operations to demonstrate best practices
- **Permission Framework** - Pre-configured role-based access control system
- **Internationalization Setup** - Multi-language support with English/Japanese examples
- **UI Integration** - Standard Redmine interface components and styling

### Development Tools
- **Quick Setup Script** - `scripts/update_plugin_info.rb` for rapid plugin customization
- **Documentation Template** - Comprehensive guides in the `docs/` directory
- **Configuration Examples** - Routes, controllers, views, and localization files
- **Security Patterns** - Proper authorization and validation implementations

## Getting Started

### Creating a New Plugin from This Template

1. **Use this template** to create a new repository:
   - Click "Use this template" on GitHub, or
   - Clone and create a new repository from this codebase

2. **Customize your plugin** using the setup script:
```bash
ruby scripts/update_plugin_info.rb
```

3. **Install in your Redmine development environment**:
```bash
cd [REDMINE_ROOT]/plugins
git clone [YOUR_NEW_PLUGIN_REPOSITORY] your_plugin_name
cd [REDMINE_ROOT]
bundle exec rake redmine:plugins:migrate RAILS_ENV=development
```

4. **Start development**:
   - Restart Redmine
   - Enable your plugin in Administration > Plugins
   - Begin customizing the sample code for your needs

### Template Testing
To test this template as-is in your development environment:
1. Follow the installation steps above
2. Enable the "Redmine Plugin Template" module in a project
3. Configure permissions and explore the sample template management features

## Template Customization

### Automated Setup (Recommended)
The included setup script streamlines the customization process:
```bash
ruby scripts/update_plugin_info.rb
```

**What the script updates:**
- Plugin ID and display name
- Author and contact information
- Version numbers and URLs
- File and class names throughout the codebase
- Internationalization keys and labels

### Manual Customization Options
For advanced customization, modify these key files:

1. **Core Plugin Configuration** (`init.rb`)
   - Plugin metadata and identification
   - Permission definitions and menu structure
   - Module registration

2. **Application Logic** (`app/` directory)
   - Controllers: Business logic and request handling
   - Views: User interface templates and forms
   - Models: Data structures (when needed)

3. **Configuration** (`config/` directory)
   - Routes: URL patterns and routing rules
   - Locales: Multi-language translations and labels

4. **Documentation** (`docs/` directory)
   - Plugin-specific documentation
   - API documentation and usage guides

## Template Structure

### File Organization
```
├── init.rb                      # Plugin registration and configuration
├── app/                         # Application code (MVC pattern)
│   ├── controllers/             # Request handling and business logic
│   └── views/                   # User interface templates
├── config/                      # Configuration files
│   ├── locales/                 # Internationalization files
│   └── routes.rb                # URL routing definitions
├── docs/                        # Comprehensive development guides
├── scripts/                     # Automation and setup tools
├── README.md                    # English documentation
└── README.ja.md                 # Japanese documentation
```

### Built-in Best Practices
- **Security Framework**: Authorization patterns and input validation
- **Redmine Integration**: Standard UI components and helper usage
- **Performance Patterns**: Efficient database queries and caching strategies
- **Error Handling**: Graceful degradation and user-friendly error messages
- **Testing Foundation**: Structure ready for unit and integration tests

### Development Workflow Support
- **Rapid Prototyping**: Working sample code to modify and extend
- **Documentation Templates**: Structured guides for common plugin scenarios
- **Internationalization**: Complete i18n implementation with fallback mechanisms
- **Version Management**: Proper plugin versioning and update patterns

## Included Documentation

This template includes extensive development documentation in the `docs/` directory:

### Core Guides
- **[docs/README.md](./docs/README.md)** - Complete documentation index and navigation
- **[docs/plugin-development/basic-structure.md](./docs/plugin-development/basic-structure.md)** - Plugin architecture and file organization
- **[docs/core-architecture/models.md](./docs/core-architecture/models.md)** - Redmine's internal structure and patterns

### Advanced Topics
- **[docs/hooks-and-events/overview.md](./docs/hooks-and-events/overview.md)** - Extension points and event system
- **[docs/examples/basic-plugin.md](./docs/examples/basic-plugin.md)** - Complete implementation walkthroughs

### Learning Resources
- Working sample code with detailed comments
- Common plugin patterns and anti-patterns
- Integration with Redmine's existing functionality
- Security and performance considerations

## Environment Requirements

**Compatible Redmine Versions:**
- Redmine 5.0 and later versions
- Ruby 3.2, 3.3, or 3.4
- Rails 7.x series

**Development Environment:**
- Git for version control
- Text editor or IDE with Ruby support
- Local Redmine installation for testing

## Template Maintenance

### Contributing to the Template
Help improve this template for the Redmine community:

1. **Template Improvements**: Fork this repository for template enhancements
2. **Documentation Updates**: Submit improvements to guides and examples
3. **Bug Reports**: Report issues with the template structure or setup tools
4. **Feature Requests**: Suggest additional tools or patterns to include

### Getting Help
- **Template Issues**: [GitHub Issues](https://github.com/douhashi/redmine_plugin_template/issues)
- **Plugin Development**: Consult the comprehensive `docs/` directory
- **Redmine Community**: Official Redmine forums and documentation

## License

This template is provided under the MIT License. See [LICENSE](LICENSE) for full details.

When you create a plugin from this template, you're free to:
- Use any license for your plugin
- Modify or remove the template attribution
- Distribute your plugin commercially or as open source

## Template Author

**Sho DOUHASHI**
- GitHub: [@douhashi](https://github.com/douhashi)
- Template Repository: [redmine_plugin_template](https://github.com/douhashi/redmine_plugin_template)
