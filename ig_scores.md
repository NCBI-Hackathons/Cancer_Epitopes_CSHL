# What do the different immunogenicity scores mean?

| Tool | Score meaning | DOI to publication | Type |
|------|---------------|--------------------|------|
| arb 1.0 | Average Relative Binding (ARB) matrix methods that directly **predict IC(50)** values allowing combination of searches involving different peptide sizes and alleles into a single global prediction| [Bui, et al., 2005](10.1007/s00251-005-0798-y)|MHC-I binding |
| bimas 1.0 | ??? | (Parker, et al., 1994)  |MHC-I binding | 
|comblibsidney 1.0 | ??? | (Sidney, et al., 2008)  |MHC-I binding | 
|epidemix 1.0 | ??? | (Feldhahn, et al., 2009)  |MHC-I binding|
|hammer 1.0| ??? | (Sturniolo, et al., 1999) |MHC-II binding | 
|netctlpan 1.1 | ??? | (Stranzl, et al., 2010) | T-cell epitope |
| netmhc 3.0a | ??? | (Lundegaard, et al., 2008) |MHC-I binding |
|netmhcii 2.2 | ??? | (Nielsen, et al., 2007) | MHC-II binding |
|netmhciipan 3.0,3.1 | ??? |  (Karosiene, et al., 2013) | MHC-II binding |
|netmhcpan 2.4,2.8 | ??? |(Hoof, et al., 2009)  |MHC-I binding | 
| pickpocket 1.1 | ??? |(Zhang, et al., 2009)  |MHC-I binding | 
|smm 1.0 | ??? |  (Peters and Sette, 2005) |MHC-I binding | 
| smmpmbec 1.0 | ??? | (Kim, et al., 2009) |MHC-I binding | 
| svmhc 1.0| ??? | (Dönnes and Elofsson, 2002)  |MHC-I binding | 
| syfpeithi 1.0 | **position-specific scoring matrices**; the matrices are manually generated based on expert knowledge and the occurrence of amino acids in naturally processed MHC ligands from the SYFPEITHI database |[Rammensee, et al., 1999](https://www.ncbi.nlm.nih.gov/pubmed/10602881)  |T-cell epitope | 
|tepitopepan 1.0 |  First, each HLA-DR binding pocket is represented by amino acid residues that have close contact with the corresponding peptide binding core residues. Then the pocket similarity between two HLA-DR molecules is calculated as the sequence similarity of the residues. Finally, for an uncharacterized HLA-DR molecule, the binding specificity of each pocket is computed as a weighted average in **pocket binding specificities** over HLA-DR molecules characterized by TEPITOPE.| [(Zhang, et al., 2012)](dx.doi.org/10.1371/journal.pone.0030483) | MHC-II binding |
| unitope 1.0| ??? | (Toussaint, et al., 2011) | T-cell epitope  |

