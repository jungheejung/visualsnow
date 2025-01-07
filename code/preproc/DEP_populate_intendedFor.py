# Provide mapping into reproin heuristic names

from heudiconv.heuristics import reproin

from heudiconv.heuristics.reproin import *

POPULATE_INTENDED_FOR_OPTS = {
    'matching_parameters': ['ImagingVolume', 'Shims'],
    'criterion': 'Closest'
}

def fix_canceled_runs(seqinfo):
    return seqinfo
reproin.fix_canceled_runs = fix_canceled_runs