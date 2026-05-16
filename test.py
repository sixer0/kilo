from collections import deque, defaultdict

T = int(input())

DIRS = [(1,0), (-1,0), (0,1), (0,-1)]

for case in range(1, T + 1):
    n = int(input())
    m = int(input())

    grid = [input().rstrip() for _ in range(n)]

    visited = [[False] * m for _ in range(n)]

    control = defaultdict(int)
    contested = 0

    for r in range(n):
        for c in range(m):

            # skip mountains or visited
            if grid[r][c] == '#' or visited[r][c]:
                continue

            # BFS region
            q = deque()
            q.append((r, c))
            visited[r][c] = True

            factions = set()

            while q:
                x, y = q.popleft()

                ch = grid[x][y]

                if 'a' <= ch <= 'z':
                    factions.add(ch)

                for dx, dy in DIRS:
                    nx = x + dx
                    ny = y + dy

                    if 0 <= nx < n and 0 <= ny < m:
                        if not visited[nx][ny] and grid[nx][ny] != '#':
                            visited[nx][ny] = True
                            q.append((nx, ny))

            # analyze region
            if len(factions) == 1:
                faction = next(iter(factions))
                control[faction] += 1
            elif len(factions) >= 2:
                contested += 1

    print(f"Case {case}:")

    for faction in sorted(control):
        print(f"{faction} {control[faction]}")

    print(f"contested {contested}")