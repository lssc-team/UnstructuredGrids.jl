module Factories

using UnstructuredGrids.Helpers
using UnstructuredGrids.Kernels
using UnstructuredGrids.Core

# **DISCLAIMER**
# This library is not supposed to be a mesh generator.
# The following mesh generation routines are mainly for
# testing purposes.

export generate

function generate(;domain,partition)
  _cartesian_grid(domain,partition)
end

# Helpers

points = zeros(0,1)
cells = [Int[]]
celltypes = Int[]
refcells = Vector{RefCell}(undef,0)
vtkid = 1
vtknodes = [1]

const VERTEX = RefCell(points,cells,celltypes,refcells,vtkid,vtknodes)

points = Float64[ -1 1; ]
cells = [[1,],[2,]]
celltypes = [1,1]
refcells = [VERTEX]
vtkid = 3
vtknodes = [1,2]

const SEGMENT = RefCell(points,cells,celltypes,refcells,vtkid,vtknodes)

points = Float64[ 0 1 0; 0 0 1]
cells = [[1,2],[2,3],[3,1]]
celltypes = [1,1,1]
refcells = [SEGMENT]
vtkid = 5
vtknodes = [1,2,3]

const TRIANGLE = RefCell(points,cells,celltypes,refcells,vtkid,vtknodes)

points = Float64[ -1 1 -1 1; -1 -1 1 1]
cells = [[1,2],[3,4],[1,3],[2,4]]
celltypes = [1,1,1,1]
refcells = [SEGMENT]
vtkid = 9
vtknodes = [1,2,4,3]

const SQUARE = RefCell(points,cells,celltypes,refcells,vtkid,vtknodes)

points = Float64[ -1 1 -1 1 -1 1 -1 1; -1 -1 1 1 -1 -1 1 1; -1 -1 -1 -1 1 1 1 1]
cells = [[1,2,3,4],[5,6,7,8],[1,2,5,6],[3,4,7,8],[1,3,5,7],[2,4,6,8]]
celltypes = [1,1,1,1,1,1]
refcells = [SQUARE]
vtkid = 12
vtknodes = [1,2,4,3,5,6,8,7]

const HEXAHEDRON = RefCell(points,cells,celltypes,refcells,vtkid,vtknodes)

function _cartesian_grid(domain,partition)
  refcell = _cartesian_grid_refcell(partition)
  points, celldata, cellptrs, celltypes, refcells = _cartesian_allocate(partition,refcell)
  _cartesian_fill_points!(points,domain,partition)
  _cartesian_fill_cells!(celldata,partition)
  UGrid(points,celldata,cellptrs,celltypes,refcells)
end

function _cartesian_allocate(partition::NTuple{D,Int},refcell) where D
  ncells = prod(partition)
  npoints = prod([ n+1 for n in partition])
  n = 2^D
  points = Array{Float64,2}(undef,(D,npoints))
  celltypes = ones(Int,ncells)
  cellptrs = fill(n,ncells+1)
  length_to_ptrs!(cellptrs)
  celldata = Vector{Int}(undef,n*ncells)
  refcells = [refcell]
  (points,celldata,cellptrs,celltypes,refcells)
end

_cartesian_grid_refcell(partition) = @notimplemented

function _cartesian_grid_refcell(partition::NTuple{2,Int})
  SQUARE
end

function _cartesian_grid_refcell(partition::NTuple{3,Int})
  HEXAHEDRON
end

_cartesian_fill_points!(points,domain,partition) = @notimplemented

function _cartesian_fill_points!(points,domain,partition::NTuple{2,Int})
  ncx = partition[1]
  ncy = partition[2]
  x0 = domain[1]
  x1 = domain[2]
  y0 = domain[3]
  y1 = domain[4]
  dx = x1-x0/ncx
  dy = y1-y0/ncy
  p = 1
  for j in 1:ncy+1
    for i in 1:ncx+1
      points[1,p] = x0 + (i-1)*dx
      points[2,p] = y0 + (j-1)*dy
      p += 1
    end
  end
end

function _cartesian_fill_points!(points,domain,partition::NTuple{3,Int})
  ncx = partition[1]
  ncy = partition[2]
  ncz = partition[3]
  x0 = domain[1]
  x1 = domain[2]
  y0 = domain[3]
  y1 = domain[4]
  z0 = domain[5]
  z1 = domain[6]
  dx = x1-x0/ncx
  dy = y1-y0/ncy
  dz = z1-z0/ncz
  p = 1
  for k in 1:ncz+1
    for j in 1:ncy+1
      for i in 1:ncx+1
        points[1,p] = x0 + (i-1)*dx
        points[2,p] = y0 + (j-1)*dy
        points[3,p] = z0 + (k-1)*dy
        p += 1
      end
    end
  end
end

_cartesian_fill_cells!(celldata,partition) = @notimplemented

function _cartesian_fill_cells!(celldata,partition::NTuple{2,Int})
  ncx = partition[1]
  ncy = partition[2]
  p = 1
  for j in 1:ncy
    for i in 1:ncx
      for b in 0:1
        for a in 0:1
          celldata[p] =  i+a + (j+b-1)*(ncx+1)
          p += 1
        end
      end
    end
  end
end

function _cartesian_fill_cells!(celldata,partition::NTuple{3,Int})
  ncx = partition[1]
  ncy = partition[2]
  ncz = partition[3]
  p = 1
  for k in 1:ncz
    for j in 1:ncy
      for i in 1:ncx
        for c in 0:1
          for b in 0:1
            for a in 0:1
              celldata[p] =  i+a + (j+b-1)*(ncx+1) + (k+c-1)*(ncx+1)*(ncy+1)
              p += 1
            end
          end
        end
      end
    end
  end
end

end # module Factories
