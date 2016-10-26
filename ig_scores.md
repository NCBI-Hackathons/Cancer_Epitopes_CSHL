# What do the different immunogenicity scores mean?

| Tool | Score meaning | DOI to publication | Type |
|------|---------------|--------------------|------|
| arb 1.0 | Average Relative Binding (ARB) matrix methods that directly **predict IC(50)** values allowing combination of searches involving different peptide sizes and alleles into a single global prediction| [Bui, et al., 2005](10.1007/s00251-005-0798-y)|MHC-I binding |
| bimas 1.0 | log-transformed **binding affinities** relative to a reference peptide | [Parker, et al., 1994](https://www.ncbi.nlm.nih.gov/pubmed/8254189)  |MHC-I binding | 
|comblibsidney 1.0 | ??? | (Sidney, et al., 2008)  |MHC-I binding | 
|epidemix 1.0 | position-specific scoring matrices. The matrices are statistically computed based on the positive training set of SVMHC. Sequence weighting and pseudo-count correction are applied to obtain the frequencies used to generate the matrices. | [Feldhahn, et al., 2009](10.1093/bioinformatics/btp409)  |MHC-I binding|
|hammer 1.0| based on position-specific scoring matrices and predicts binding peptides for MHC class II | [Sturniolo, et al., 1999](https://www.ncbi.nlm.nih.gov/pubmed/10385319) |MHC-II binding | 
|netctlpan 1.1 | ??? | (Stranzl, et al., 2010) | T-cell epitope |
| netmhc 3.0a | binding affinity | (Lundegaard, et al., 2008) |MHC-I binding |
|netmhcii 2.2 | binding affinity | (Nielsen, et al., 2007) | MHC-II binding |
|netmhciipan 3.0,3.1 |  |  [Karosiene, et al., 2013] | MHC-II binding |
|netmhcpan 2.4,2.8 | Here, we present NetMHCpan-2.0, a method that generates **quantitative predictions of the affinity of any peptide-MHC class I interaction** |[Hoof, et al., 2009](https://www.ncbi.nlm.nih.gov/pubmed/19002680)  |MHC-I binding | 
| pickpocket 1.1 | For MHC molecules with known specificities, we established a library of pocket-residues and corresponding binding specificities. The binding specificity for a novel MHC molecule is calculated as the average of the specificities of MHC molecules in this library weighted by the similarity of their pocket-residues to the query. This PickPocket method is demonstrated to accurately predict **MHC-peptide binding** for a broad range of MHC alleles, including human and non-human species. |[Zhang, et al., 2009](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2732311/)  |MHC-I binding | 
|smm 1.0 | binding affinity |  (Peters and Sette, 2005) |MHC-I binding | 
| smmpmbec 1.0 | binding affinity | (Kim, et al., 2009) |MHC-I binding | 
| svmhc 1.0| support vector machine classification to predict MHC-binding peptides. The method is trained on known MHC-binding peptides from the SYFPEITHI database | [Dönnes and Elofsson, 2002](dx.doi.org/10.1093/nar/gkl284)  |MHC-I binding | 
| syfpeithi 1.0 | **position-specific scoring matrices**; the matrices are manually generated based on expert knowledge and the occurrence of amino acids in naturally processed MHC ligands from the SYFPEITHI database |[Rammensee, et al., 1999](https://www.ncbi.nlm.nih.gov/pubmed/10602881)  |T-cell epitope | 
|tepitopepan 1.0 |  First, each HLA-DR binding pocket is represented by amino acid residues that have close contact with the corresponding peptide binding core residues. Then the pocket similarity between two HLA-DR molecules is calculated as the sequence similarity of the residues. Finally, for an uncharacterized HLA-DR molecule, the binding specificity of each pocket is computed as a weighted average in **pocket binding specificities** over HLA-DR molecules characterized by TEPITOPE.| [(Zhang, et al., 2012)](dx.doi.org/10.1371/journal.pone.0030483) | MHC-II binding |
| unitope 1.0|support vector classification method, combines structural and sequence information in a machine-learning framework, The allele encoding uses pocket profiles derived from crystal structures of peptide:MHC complexes. The peptides are also encoded using physico-chemical properties  | [Toussaint, et al., 2010](dx.doi.org/10.1186/1471-2105-11-S8-S7), [Toussaint et al. 2011](http://dl.acm.org/citation.cfm?id=2147805.2147905) | T-cell epitope  |

