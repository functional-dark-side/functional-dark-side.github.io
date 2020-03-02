#!/usr/bin/env python
"""
@author: inodb

This is the same script as gen_input_table.py from CONCOCT. It is used in
metassemble to determine contig coverage from a bam file and a fasta file.
"""
import sys
import os
import argparse
import subprocess
from signal import signal, SIGPIPE, SIG_DFL

from Bio import SeqIO, SeqUtils


def get_gc_and_len_dict(fastafile):
    """Creates a dictionary with the fasta id as key and GC and length as keys
    for the inner dictionary."""
    out_dict = {}

    for rec in SeqIO.parse(fastafile, "fasta"):
        out_dict[rec.id] = {}
        out_dict[rec.id]["length"] = len(rec.seq)
        out_dict[rec.id]["GC"] = SeqUtils.GC(rec.seq)

    return out_dict


def get_bedcov_dict(bedcoverage):
    """Uses the BEDTools genomeCoverageBed histogram output to determine mean
    coverage and percentage covered for each contig.

    Returns dict with fasta id as key and percentage covered and cov_mean as
    keys for the inner dictionary."""
    out_dict = {}

    # Check if given argument is a file, otherwise use the content of the
    # variable
    if os.path.isfile(bedcoverage):
        fh = open(bedcoverage)
    else:
        fh = bedcoverage.split('\n')[:-1]

    for line in fh:
        cols = line.split()

        try:
            d = out_dict[cols[0]]
        except KeyError:
            d = {}
            out_dict[cols[0]] = d

        if int(cols[1]) == 0:
            d["percentage_covered"] = 100 - float(cols[4]) * 100.0
        else:
            d["cov_mean"] = d.get("cov_mean", 0) + int(cols[1]) * float(cols[4])

    return out_dict


def print_sample_columns(t, header="cov_mean_sample_"):
    sys.stdout.write((("\t" + header + "%s") * len(t)) % t)


def print_input_table(fastadict, bedcovdicts, samplenames=None):
    """Writes the input table for Probin to stdout. See hackathon google
    docs."""

    # Header
    sys.stdout.write("contig\tlength\tGC")
    if samplenames is None:
        # Use index if no sample names given in header
        print_sample_columns(tuple(range(len(bedcovdicts))), "cov_mean_sample_")
        print_sample_columns(tuple(range(len(bedcovdicts))), "percentage_covered_sample_")
    else:
        # Use given sample names in header
        assert(len(samplenames) == len(bedcovdicts))
        print_sample_columns(tuple(samplenames), "cov_mean_sample_")
        print_sample_columns(tuple(samplenames), "percentage_covered_sample_")
    sys.stdout.write("\n")

    # Content
    assert(len(fastadict) > 0)
    for acc in fastadict:
        # fasta stats
        sys.stdout.write("%s\t%d\t%f" %
            (
                acc,
                fastadict[acc]['length'],
                fastadict[acc]['GC']
            )
        )

        # Print mean
        for bcd in bedcovdicts:
            try:
                # Print cov mean
                sys.stdout.write("\t%f" % (bcd[acc]["cov_mean"]))
            except KeyError:
                # No reads mapped to this contig
                sys.stdout.write("\t0")

        # Print percentage covered
        for bcd in bedcovdicts:
            try:
                # Print percentage covered
                sys.stdout.write("\t%f" % (bcd[acc]["percentage_covered"]))
            except KeyError:
                if acc in bcd and "cov_mean" in bcd[acc]:
                    # all reads were covered
                    sys.stdout.write("\t100")
                else:
                    # No reads mapped to this contig
                    sys.stdout.write("\t0")

        sys.stdout.write("\n")


def gen_contig_cov_per_bam_table(fastafile, bamfiles, samplenames=None, isbedfiles=False):
    """Reads input files into dictionaries then prints everything in the table
    format required for running ProBin."""
    bedcovdicts = []

    # Determine coverage information from bam file using BEDTools
    for i, bf in enumerate(bamfiles):
        if isbedfiles is False:
            p = subprocess.Popen(["genomeCoverageBed", "-ibam", bf], stdout=subprocess.PIPE)
            out, err = p.communicate()
            if p.returncode != 0:
                sys.stderr.write(out)
                raise Exception('Error with genomeCoverageBed')
            else:
                bedcovdicts.append(get_bedcov_dict(out))
        else:
            bedcovdicts.append(get_bedcov_dict(bf))

    print_input_table(get_gc_and_len_dict(fastafile), bedcovdicts, samplenames=samplenames)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("fastafile", help="Contigs fasta file")
    parser.add_argument("bamfiles", nargs='+', help="BAM files with mappings to contigs")
    parser.add_argument("--samplenames", default=None, help="File with sample names, one line each. Should be same nr as bamfiles.")
    parser.add_argument("--isbedfiles", action='store_true',
        help="The bamfiles argument are outputs of genomeCoverageBed, not the actual bam file. Skips running genomeCoverageBed from within this script.")
    args = parser.parse_args()

    # Get sample names
    if args.samplenames is not None:
        samplenames = [s[:-1] for s in open(args.samplenames).readlines()]
        if len(samplenames) != len(args.bamfiles):
            raise Exception("Nr of names in samplenames should be equal to nr of given bamfiles")
    else:
        samplenames = None

    # ignore broken pipe error when piping output
    # http://newbebweb.blogspot.pt/2012/02/python-head-ioerror-errno-32-broken.html
    signal(SIGPIPE, SIG_DFL)

    gen_contig_cov_per_bam_table(args.fastafile, args.bamfiles,
        samplenames=samplenames, isbedfiles=args.isbedfiles)
