# from mpi4py import MPI

# comm = MPI.COMM_WORLD
# size = comm.Get_size()
# rank = comm.Get_rank()
# print(f"Process {rank} of {size} is alive.")

## Why is the Output Order Random?
# All four processes call print() at roughly the same moment. The operating system schedules them independently. 
# There is no guarantee which one reaches the terminal output first.

## spmd_pattern.py
# from mpi4py import MPI

# comm = MPI.COMM_WORLD
# rank = comm.Get_rank()
# size = comm.Get_size()

# SERVER_RANK = 0    # by convention, rank 0 is the coordinator

# if rank == SERVER_RANK:
#     # I am the coordinator --- collect and present results
#     print(f"I am the server (rank {rank}). Waiting for {size - 1} workers.")
# else:
#     # I am a worker --- compute my portion of the problem
#     print(f"I am worker rank {rank}. Ready to compute.")


# ordered_print.py
# from mpi4py import MPI

# comm = MPI.COMM_WORLD
# rank = comm.Get_rank()
# size = comm.Get_size()
# ROOT = 0

# if rank == ROOT:
#     # Print our own message first
#     print(f"Process {ROOT}: I am the coordinator")

#     # Receive and print each worker's message in order
#     for worker in range(1, size):
#         message = comm.recv(source=worker, tag=0)
#         print(f"Process {worker}: {message}")

# else:
#     # Each worker sends its message to the coordinator
#     comm.send(f"I am worker {rank}", dest=ROOT, tag=0)



# data_division.py
# this code sums numbers from 0 to 99 (100 items)
# from mpi4py import MPI

# comm = MPI.COMM_WORLD
# rank = comm.Get_rank()
# size = comm.Get_size()

# total_items = 100
# items_per_process = total_items // size

# # Each process figures out its own slice of work
# start = rank * items_per_process
# end   = start + items_per_process

# print(f"Process {rank}: responsible for items {start} to {end - 1}")

# # Each process independently sums its slice
# local_sum = sum(range(start, end))
# print(f"Process {rank}: local sum = {local_sum}")



# coordinator_pattern.py  (pseudocode skeleton)
# from mpi4py import MPI

# comm = MPI.COMM_WORLD
# rank = comm.Get_rank()
# size = comm.Get_size()
# ROOT = 0

# if rank == ROOT:
#     # ── Coordinator responsibilities ──
#     # 1. Prepare / load the data
#     # 2. Distribute work to workers (send / scatter)
#     # 3. Collect results from workers (recv / reduce)
#     # 4. Print / save the final answer
#     pass
# else:
#     # ── Worker responsibilities ──
#     # 1. Receive my portion of work
#     # 2. Compute locally
#     # 3. Send result back to coordinator


# coordinator_pattern.py
from mpi4py import MPI

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()
ROOT = 0

if rank == ROOT:
    # 1. Prepare the data
    numbers = [1, 2, 3, 4, 5, 6, 7, 8]   # 8 numbers, 1 chunk per worker
    chunk_size = len(numbers) // (size - 1) # divide among workers (not root)

    # 2. Distribute work to workers
    for worker in range(1, size):
        start = (worker - 1) * chunk_size
        chunk = numbers[start : start + chunk_size]
        comm.send(chunk, dest=worker, tag=0)
        print(f"Coordinator sent {chunk} to worker {worker}")

    # 3. Collect results from workers
    total = 0
    for worker in range(1, size):
        result = comm.recv(source=worker, tag=1)
        print(f"Coordinator received {result} from worker {worker}")
        total += result

    # 4. Print the final answer
    print(f"\nFinal total (sum of squares): {total}")

else:
    # 1. Receive my portion of work
    chunk = comm.recv(source=ROOT, tag=0)

    # 2. Compute locally  (square each number, then sum)
    local_result = sum(x ** 2 for x in chunk)
    print(f"Worker {rank}: got {chunk}, computed {local_result}")

    # 3. Send result back to coordinator
    comm.send(local_result, dest=ROOT, tag=1)