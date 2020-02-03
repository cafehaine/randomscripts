#!/usr/bin/env python3
"""
A small cli tool to generate dependency graphs for the aur.

Depends on python requests, networkx and pydot.

To generate a png of the graph you can use the following command:
dot -Tpng graph.dot -ograph.png
"""

from argparse import ArgumentParser

from requests import get
from networkx import DiGraph
from networkx.drawing.nx_pydot import write_dot

AUR_RPC_URL = "https://aur.archlinux.org/rpc/"

class Query:
    def __init__(self, parent, relation, args):
        self.parent = parent
        self.relation = relation
        self.args = args
        self.args['v'] = 5
        self.args['type'] = 'search'

parser = ArgumentParser(description='Generate a graph of the aur packages that depend on ones maintained by a maintainer.')
parser.add_argument('--maintainer', nargs='?', default='cafehaine', help='the maintainer')

args = parser.parse_args()

G = DiGraph()

queries = [
    Query(None, None, {'by': 'maintainer', 'arg': args.maintainer})
]

print("==> Fetching informations")
while queries:
    query = queries.pop()
    print("by {}: {}".format(query.args['by'], query.args['arg']))
    r = get(AUR_RPC_URL, params=query.args)
    json = r.json()
    for package in json['results']:
        name = package['Name']
        if package['Maintainer'] == args.maintainer:
            G.add_node(name, color='red')
        else:
            G.add_node(name)
        if query.parent:
            G.add_edge(query.parent, name)
        queries.append(Query(name, 'depends', {'by': 'depends', 'arg': name}))
        queries.append(Query(name, 'makedepends', {'by': 'makedepends', 'arg': name}))
        queries.append(Query(name, 'checkdepends', {'by': 'checkdepends', 'arg': name}))

print("==> Done fetching informations")
print("==> Saving graph as graph.dot")
write_dot(G, 'graph.dot')
print("==> Done saving.")
print("To generate a visual representation of this graph, run the following command:")
print("> dot graph.dot -Tpng -o graph.png")
