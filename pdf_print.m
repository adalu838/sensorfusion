function pdf_print(fileName)
%pdf_print(fileName,sim)
%fileName: 'hej.pdf'
if isunix
    plot_export_size=6;%cm
else
    plot_export_size=18;%cm
end
%set(gcf,'PaperUnits','cm');
set(gcf,'PaperSize', [plot_export_size plot_export_size]);
set(gcf,'PaperPosition',[0 0 plot_export_size plot_export_size]);
set(gcf,'PaperPositionMode','Manual');
print(gcf, '-dpdf', fileName);


