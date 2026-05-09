# mat_mul.py
# Run with: mpiexec -n 4 python mat_mul.py
# (1 coordinator + 3 workers, one chunk of rows per worker)

from mpi4py import MPI

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()
ROOT = 0

# ── Tag constants ──────────────────────────────────────────────────────────
TAG_ROWS   = 0   # coordinator → worker: your rows from matrix A
TAG_MATRIX = 1   # coordinator → worker: the full matrix B
TAG_RESULT = 2   # worker → coordinator: your computed rows of C

# ── Helper: multiply a list of rows by a full matrix ──────────────────────
# This is the local computation each worker does.
# rows_of_a : a list of rows, e.g. [[1,2],[3,4]]
# matrix_b  : the full B matrix
# Returns the corresponding rows of the result matrix C.
def multiply_rows(rows_of_a, matrix_b):
    result = []

    for row_a in rows_of_a:                        # one row from A

        result_row = []

        for col in range(len(matrix_b[0])):        # for each column in B

            dot_product = 0

            for pos in range(len(row_a)):          # walk across row A and down column B
                a_element = row_a[pos]             # element from the row of A
                b_element = matrix_b[pos][col]     # element from the column of B
                dot_product = dot_product + a_element * b_element

            result_row.append(dot_product)         # one cell done

        result.append(result_row)                  # one row done

    return result

# ══════════════════════════════════════════════════════════════════════════
if rank == ROOT:

    # ── Step 1: Define the matrices 
    # Using small 6×6 matrices so output is easy to read.
    # We have 3 workers, so 6 rows splits cleanly into 3 chunks of 2 rows each.
    A = [
        [1, 2, 3, 4, 5, 6],
        [7, 8, 9, 1, 2, 3],
        [4, 5, 6, 7, 8, 9],
        [2, 4, 6, 8, 1, 3],
        [5, 5, 5, 5, 5, 5],
        [9, 8, 7, 6, 5, 4],
    ]
    B = [
        [1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0],
        [0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 1, 0],
        [0, 0, 0, 0, 0, 1],
    ]
    # Note: B is the identity matrix, so C should equal A exactly.
    # This makes it very easy to verify correctness.

    num_rows   = len(A)
    num_workers = size - 1                         # exclude coordinator itself
    chunk_size  = num_rows // num_workers

    print(f"Matrix size: {num_rows} x {num_rows}")
    print(f"Workers: {num_workers}, rows per worker: {chunk_size}\n")

    # ── Step 2: Send each worker its rows of A AND the full matrix B 
    # Two sends per worker, two different tags.
    for worker in range(1, size):
        start     = (worker - 1) * chunk_size
        row_chunk = A[start : start + chunk_size]

        comm.send(row_chunk, dest=worker, tag=TAG_ROWS)    # this worker's slice
        comm.send(B,         dest=worker, tag=TAG_MATRIX)  # B is the same for all
        print(f"Coordinator -> worker {worker}: rows {start} to {start + chunk_size - 1}")

    # ── Step 3: Collect result rows from each worker 
    # We collect in rank order so the final matrix rows are in the right order.
    result_rows = []
    for worker in range(1, size):
        partial = comm.recv(source=worker, tag=TAG_RESULT)
        result_rows.extend(partial)                # extend appends all rows, not a nested list
        print(f"Coordinator <- worker {worker}: received {len(partial)} result rows")

    # ── Step 4: Print the final matrix 
    print("\nResult matrix C = A x B:")
    for row in result_rows:
        print(" ", row)

    print("\nExpected (B is identity, so C should equal A):")
    for row in A:
        print(" ", row)

# ══════════════════════════════════════════════════════════════════════════
else:

    # ── Step 1: Receive our slice of A and the full matrix B ───────────────
    my_rows  = comm.recv(source=ROOT, tag=TAG_ROWS)
    matrix_b = comm.recv(source=ROOT, tag=TAG_MATRIX)

    print(f"Worker {rank}: received {len(my_rows)} rows to process")

    # ── Step 2: Compute our rows of the result locally ─────────────────────
    my_result = multiply_rows(my_rows, matrix_b)

    # ── Step 3: Send our result rows back to the coordinator ───────────────
    comm.send(my_result, dest=ROOT, tag=TAG_RESULT)
    print(f"Worker {rank}: sent {len(my_result)} result rows back")


# Assignment: Parallel Vector Addition using MPI
# Write a parallel MPI program that adds two equal-length vectors
# using one coordinator process and multiple worker processes.

# The coordinator should create two vectors,
# split them into chunks, send each chunk to a worker,
# and collect the partial results.
# Each worker should receive its chunk,
# add the corresponding elements of the two vectors locally,
# and send the result back to the coordinator.
# The coordinator then combines all returned chunks into the final vector and prints it.