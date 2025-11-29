# Custom Instructions for Ruby on Rails Code Review

## General Code Review Guidelines
- **Provide direct, actionable instructions with clear reasoning and justification**
- **Include relevant references, documentation links, or examples when available**

## Ruby on Rails Specific Guidelines

### Database and Performance
- **Plain SQL Detection**: When reviewing Ruby on Rails code containing plain SQL queries, suggest the standard Rails ActiveRecord approach instead
- **N+1 Query Detection**: When reviewing code that loads associations in loops, identify potential N+1 query problems and suggest using `includes`, `joins`, or `preload` to optimize database queries
- Provide specific ActiveRecord methods and explain why they are preferred over raw SQL

### Code Generation and Structure
- **Rails Generators**: When reviewing manually created Rails files (models, controllers, migrations), suggest using Rails generators instead when appropriate
- **Fat Controller Prevention**: When reviewing controllers with business logic, data processing, or complex operations, suggest moving logic to models, services, or concerns
- Recommend keeping controllers thin and focused on HTTP request/response handling

### Code Style and Ruby Idioms
- **Ruby Idioms**: When reviewing code that doesn't follow Ruby conventions, suggest more idiomatic Ruby approaches:
  - Use implicit returns instead of explicit `return` statements
  - Prefer blocks and iterators over traditional loops
  - Use symbols appropriately
  - Embrace duck typing and Ruby's dynamic nature
  - Use meaningful method names and follow Ruby naming conventions

### Magic Values Prevention
- **Magic Numbers/Strings Detection**: When reviewing code containing hard-coded numbers, strings, or other literal values that have business meaning, suggest extracting them to constants, enums, or configuration
- **Constant Extraction**: Recommend creating descriptive constants for:
  - Status codes and states
  - Business rules and thresholds
  - API endpoints and keys
  - Time intervals and limits
  - Error messages and codes
- **Rails Enums**: For status-like values, suggest using Rails enums instead of magic strings or numbers
- **Configuration Files**: For environment-specific values, recommend using Rails credentials, environment variables, or configuration files

### Security Best Practices
- **SQL Injection Prevention**: Flag any string interpolation in SQL queries and suggest parameterized queries or ActiveRecord methods
- **Mass Assignment Protection**: When reviewing controller params, ensure proper strong parameters usage and suggest `permit` lists
- **Authentication/Authorization**: Review for proper authentication checks and suggest using established gems like Pundit
- **Sensitive Data Exposure**: Flag hardcoded secrets, API keys, or passwords and suggest Rails credentials or environment variables
- **Input Validation**: Check for proper model validations and sanitization of user inputs

### API Best Practices
- **Serialization**: When building APIs, suggest using serializers (jsonapi-serializer) instead of manual JSON building
- **Versioning**: Recommend proper API versioning strategies
- **Rate Limiting**: Suggest implementing rate limiting for public APIs
- **Documentation**: Recommend API documentation tools (Swagger, RSpec API Documentation)
- **HTTP Status Codes**: Ensure proper HTTP status code usage in API responses
- **RESTful Routes**: When reviewing custom routes or non-standard actions, suggest using standard RESTful actions (index, show, new, create, edit, update, destroy)

### Testing
- **RSpec Tests**: When reviewing test files or code without tests, provide guidance on:
  - Writing behavior-driven tests instead of implementation-focused tests
  - Using proper RSpec syntax and matchers
  - Following testing best practices (arrange-act-assert pattern)
  - Suggesting missing test coverage for edge cases

### Gem Management
- **Gem Analysis**: When reviewing Ruby on Rails code with new gem additions, analyze if there are better alternatives with similar functionality
- Give straightforward recommendations for gem alternatives with clear justification for the suggestion
- Consider factors like maintenance status, performance, security, and community adoption

### Reusability and Architecture Patterns

#### Service Objects vs Models
- **Fat Models Detection**: When reviewing model files exceeding 100 lines or containing complex business logic, suggest extracting to Service Objects
- **Service Objects Usage**: When reviewing controllers or models with the following scenarios, suggest using Service Objects:
  - Cross-model complex operations
  - External API calls
  - Complex data processing and transformation
  - Multi-step operations requiring transactions
- **Single Responsibility Principle**: Ensure each Service Object handles only one clear business function
- **Naming Conventions**: Service Objects should use verb endings (e.g., `ProcessOrderService`, `SendEmailService`)

#### Reusability Patterns
- **Concerns**: When multiple models share the same methods or callbacks, suggest using Concerns
- **Modules**: For pure functional methods, suggest using independent Modules
- **Inheritance**: Use inheritance only for true "is-a" relationships

### Database and Performance
- **Migration Safety**: Flag dangerous migrations (removing columns, changing types) and suggest safe alternatives
- **Index Recommendations**: When reviewing queries with `where`, `joins`, or `order`, suggest adding appropriate indexes
- **Database Constraints**: Recommend database-level constraints (foreign keys, unique indexes) over application-level only

### Caching
- **Fragment Caching**: Suggest caching expensive view fragments
- **Query Caching**: Recommend `Rails.cache` for expensive database queries
- **Cache Keys**: Ensure proper cache key versioning and invalidation strategies

### Error Handling
- **Rescue Clauses**: Avoid bare `rescue` without exception class
- **Custom Exceptions**: Suggest creating domain-specific exception classes
- **Error Logging**: Ensure proper error tracking (Sentry, Rollbar)

#### Service Objects
- **Return Values**: Service Objects should return Result objects (success/failure with data/errors)
- **Dependency Injection**: Pass dependencies as constructor arguments
- **Testing**: Each Service Object should have comprehensive unit tests
- **Example Structure**:
  ```ruby
  class ProcessOrderService
    def initialize(order, payment_gateway = PaymentGateway.new)
      @order = order
      @payment_gateway = payment_gateway
    end

    def call
      # Implementation
      ImportCsvResultSerializer.success(data: @order)
    rescue StandardError => e
      ImportCsvResultSerializer.failure(error: e.message)
    end
  end
  ```
### Security Best Practices
- **CSRF Protection**: Ensure CSRF tokens are properly implemented
- **XSS Prevention**: Flag `html_safe` or `raw` usage without sanitization
- **CORS Configuration**: Review CORS settings for API endpoints
- **Dependency Scanning**: Recommend Bundler Audit for vulnerable gems
- **Content Security Policy**: Suggest implementing CSP headers

### Code Review Tools
- **Documentation**: Use YARD for code documentation
- Generate documentations with markdown format for any complex suggestions or explanations /docs
- Update link references to point to the generated markdown files in /docs in Readme.md (root)
