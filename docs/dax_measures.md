Total Sales =
SUM('vw_dashboard_base'[sales])

Total Profit =
SUM('vw_dashboard_base'[profit])

Profit Margin % =
DIVIDE([Total Profit], [Total Sales], 0)

Top Region =
VAR RegionTable = TOPN( 1, ALLSELECTED('vw_dashboard_base'[region]),
        [Total Profit], DESC,'vw_dashboard_base'[region],
        ASC) RETURN MAXX( RegionTable,'vw_dashboard_base'[region] )

Top Region Profit =
VAR RegionTable = TOPN( 1, ALLSELECTED('vw_dashboard_base'[region]),
        [Total Profit], DESC, 'vw_dashboard_base'[region], ASC )
RETURN MAXX( RegionTable, [Total Profit])

Top Category =
VAR CategoryTable = TOPN( 1, ALLSELECTED('vw_dashboard_base'[category]), [Total Profit],
        DESC,'vw_dashboard_base'[category], ASC )
RETURN MAXX( CategoryTable, 'vw_dashboard_base'[category])



