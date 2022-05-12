## Pipeline
Pipeline represents a projects integration and delivery flow.

Pipelines comprise:
- Jobs, which define what to do. For example, jobs that compile or test code.
- Stages, which define when to run the jobs. For example, stages that run tests after stages that compile the code.

```klovercloud/pipeline/pipeline.yaml``` file contains pipeline configuration.
## Step
Steps are jobs or tasks with successors that make a Pipeline.
## Process 
A process is an object of a Pipeline. When a Pipeline is triggered a new Process starts.
