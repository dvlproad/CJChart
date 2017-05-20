# Chart
chart


#### Screenshots
![Example](./Screenshots/Demo.gif "Demo")
![Example](./Screenshots/Demo.png "Demo")


## 一、

### How to use


## 二、iOS charts
#### 问1：如何设置柱状图的宽度
```
	BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.f]];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = 0;
    //formatter.negativeSuffix = @"人";
    //formatter.positiveSuffix = @"人";
    [data setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:formatter]];
    [data setValueTextColor:UIColor.whiteColor];
    [data setValueFont:[UIFont boldSystemFontOfSize:12]];
    
    //设置柱状图的宽度（默认0.85）
    switch (entries.count) {
        case 1:
        {
            [data setBarWidth:0.1];
            break;
        }
        case 2:
        {
            [data setBarWidth:0.2];
            break;
        }
        case 3:
        {
            [data setBarWidth:0.4];
            break;
        }
        case 4:
        {
            [data setBarWidth:0.5];
            break;
        }
        case 5:
        {
            [data setBarWidth:0.6];
            break;
        }
        case 6:
        {
            [data setBarWidth:0.7];
            break;
        }
        default:
        {
            [data setBarWidth:0.85];
            break;
        }
    }
    
    _barChartView.fitBars = NO;
    _barChartView.data = data;
```

## 完！
