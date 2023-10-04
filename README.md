# ResourceRegistry

A service discovery mechanism for Factorial backend

## Features

- Schema registry for resources, maybe we can infere them from entities
- Relate events to resources actions (CRUD and not CRUD)

## Examples

```ruby
ResourceRegistry.add(
  Resource.new(
    slug: 'employees', # Maybe we will need component Namespacing / Category to prefix routes
    repository: Employees::Repositories::Employees,
    verbs: {
      index: {
        type: :read
      }, # => Repository.read
      show: {
        type: :read
      },
      create: {
        type: :write
      }, # => Repository.create
      update: {
        type: :write
      },
      destroy: {
        event: Employee::Events::EmployeeRemoved
      },
      # RPCs they are all http POST method
      approve: {
        event: Employee::Events::EmployeeApproved
      } # => Repository.approve
    }
  )
)
```
