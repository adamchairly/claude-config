WebSearch is always allowed. Use it if neccesary.

## Architecture & layering
 
Use **Clean Architecture** boundaries if the architecture uses it:
 
- **API (Presentation)**
  - Controllers / endpoints only
  - HTTP concerns (routing, status codes, auth)
  - No business logic
- **Application**
  - CQRS (Commands / Queries)
  - Handlers, validators, pipeline behaviors
- **Domain**
  - Entities, Value Objects, Domain Services
  - Domain Events
  - **No EF Core or infrastructure dependencies**
- **Infrastructure**
  - Persistence, external services, integrations
 
 
### Explicit rules
 
- ❌ **Repository pattern is forbidden**
- ❌ Generic repositories are not allowed
- Data access must be done via:
  - Application-level abstractions (e.g. `IOrderReadStore`, `IOrderWriteStore`)
  - Or directly via DbContext in Infrastructure
 
**Why:**
- Repository pattern hides query intent
- Leads to anemic abstractions
- Conflicts with CQRS projections
 
 
### CQRS with MediatR
 
- Separate **Commands** and **Queries**
- One request → one handler
- Commands:
  - Do **not** return rich domain objects
  - Return IDs, lightweight results, or explicit DTOs
- Queries:
  - Read-only
  - No side effects
- Always:
  - Accept `CancellationToken`
  - Pass it through
  - Use async all the way
 
## Naming
- Commands: `CreateXCommand`, `UpdateXCommand`, `DeleteXCommand`
- Handlers: `XCommandHandler`, `XQueryHandler`
- Queries: `GetXQuery`, `ListXQuery`
- Results: `XResult`, `XDto`
 
---
 
## Controllers (Presentation layer)
 
### Core principles
- Controllers are a **very thin layer**
- Their only responsibilities:
  - HTTP mapping (route, verb, status code)
  - Model binding
  - Calling MediatR
  - Returning results
 
### Rules
- ❌ **Do not implement business logic in controllers**
- ❌ **Do not inject repositories or DbContexts**
- ❌ **Do not use PostModels if avoidable**
- ✅ **Prefer using Commands and Queries directly**
 
### Preferred pattern
```csharp
[HttpPost]
public async Task<IActionResult> Create(CreateOrderCommand command, CancellationToken ct)
{
    var result = await _mediator.Send(command, ct);
    return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
}
```
 
**Why:**
- Keeps API consistent with Application layer
- Avoids duplicate models
- Simplifies validation and testing
 
---

## Global usings & style
 
- File-scoped namespaces
- Nullable reference types enabled
- Prefer `record` for immutable DTOs
- Use `required` where appropriate
- ❌ **Never use `#region` / `#endregion`** - Regions hide code complexity; refactor instead
- ✅ **Prefer `internal` classes** - Use `internal` instead of `public` when the class is not used outside the assembly
 
### Method parameters – unwrapped style
 
- ✅ **Always use unwrapped (inline) parameters** by default
- ❌ **Do not wrap parameters** unless parameter count exceeds 7
- If more than 7 parameters → wrapping is allowed

### Code size & simplicity
 
- Prefer **short, expressive code**
- Avoid over-abstraction
- One method = one responsibility
- Early returns over nested logic
- If a method needs comments to explain *how* it works, it is too complex
 
---