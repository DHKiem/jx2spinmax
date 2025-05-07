# jx2spinmax

Install:
```
julia> ]
pkg> add https://github.com/DHKiem/jx2spinmax.git
```

Usage: 
```
julia> import jx2spinmax
julia> jx2spinmax.create_col([1,2,3], [1,2,3], "./jx2.col.spin_0.0")
julia> jx2spinmax.create_col([1,2,3], [1,2,3], "./jx2.col.spin_0.0", toml = "MFT.toml")
julia> jx2spinmax.create_col([1,2,3], [1,2,3], "./jx2.col.spin_0.0", spinupdn=[1,-1,1], toml = "MFT.toml") # 1 for up, -1 for down # default: all up
```
